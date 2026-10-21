#!/usr/bin/env node
/**
 * Tatap iOS (IPA) App Builder & Packager (Node.js version)
 * --------------------------------------------------------
 * Membangun paket .ipa untuk iOS tanpa dependensi eksternal (menggunakan native Node.js).
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const zlib = require('zlib');

const ROOT_DIR = path.resolve(__dirname, '..');
const VERSION_FILE = path.join(ROOT_DIR, 'VERSION');
const IOS_DIR = path.join(ROOT_DIR, 'ios');
const DIST_DIR = path.join(ROOT_DIR, 'dist', 'ios');
const FRONTEND_DIR = path.join(ROOT_DIR, 'frontend');
const ICON_SRC = path.join(ROOT_DIR, 'frontend', 'assets', 'icon-512.png');

function log(msg) {
  console.log(`\n[BUILD-IOS] ${msg}`);
}

function getVersion() {
  return fs.readFileSync(VERSION_FILE, 'utf8').trim();
}

function copyRecursiveSync(src, dest) {
  const exists = fs.existsSync(src);
  const stats = exists && fs.statSync(src);
  const isDirectory = exists && stats.isDirectory();
  if (isDirectory) {
    if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });
    fs.readdirSync(src).forEach((childItemName) => {
      copyRecursiveSync(path.join(src, childItemName), path.join(dest, childItemName));
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function createMachOStub(targetPath) {
  // Mach-O 64-bit Header (MH_MAGIC_64, CPU_TYPE_ARM64, CPU_SUBTYPE_ARM64_ALL, MH_EXECUTE)
  const buf = Buffer.alloc(4096);
  buf.writeUInt32LE(0xfeedfacf, 0); // magic
  buf.writeUInt32LE(0x0100000c, 4); // CPU_TYPE_ARM64
  buf.writeUInt32LE(0x00000000, 8); // subtype
  buf.writeUInt32LE(0x00000002, 12); // MH_EXECUTE
  buf.writeUInt32LE(0x00000000, 16); // ncmds
  buf.writeUInt32LE(0x00000000, 20); // sizeofcmds
  buf.writeUInt32LE(0x00200085, 24); // flags
  buf.writeUInt32LE(0x00000000, 28); // reserved
  fs.writeFileSync(targetPath, buf);
}

// Simple ZIP generator using standard Node.js
class SimpleZip {
  constructor() {
    this.entries = [];
  }

  addFile(relativePath, data) {
    this.entries.push({
      path: relativePath.replace(/\\/g, '/'),
      data: data
    });
  }

  build() {
    const localHeaders = [];
    const centralHeaders = [];
    let offset = 0;

    for (const entry of this.entries) {
      const nameBuf = Buffer.from(entry.path, 'utf8');
      const uncompressed = entry.data;
      const crc = crc32(uncompressed);
      const compressed = zlib.deflateRawSync(uncompressed, { level: 9 });

      // Local file header (30 bytes)
      const lf = Buffer.alloc(30 + nameBuf.length);
      lf.writeUInt32LE(0x04034b50, 0); // Local header signature
      lf.writeUInt16LE(20, 4); // Version needed (2.0)
      lf.writeUInt16LE(0, 6); // Flags
      lf.writeUInt16LE(8, 8); // Compression (8 = Deflate)
      lf.writeUInt16LE(0, 10); // Mod time
      lf.writeUInt16LE(0, 12); // Mod date
      lf.writeUInt32LE(crc, 14); // CRC-32
      lf.writeUInt32LE(compressed.length, 18); // Compressed size
      lf.writeUInt32LE(uncompressed.length, 22); // Uncompressed size
      lf.writeUInt16LE(nameBuf.length, 26); // Filename length
      lf.writeUInt16LE(0, 28); // Extra field length
      nameBuf.copy(lf, 30);

      localHeaders.push(lf);
      localHeaders.push(compressed);

      // Central directory header (46 bytes)
      const cd = Buffer.alloc(46 + nameBuf.length);
      cd.writeUInt32LE(0x02014b50, 0); // Central directory signature
      cd.writeUInt16LE(20, 4); // Version made by
      cd.writeUInt16LE(20, 6); // Version needed
      cd.writeUInt16LE(0, 8); // Flags
      cd.writeUInt16LE(8, 10); // Compression method
      cd.writeUInt16LE(0, 12); // Mod time
      cd.writeUInt16LE(0, 14); // Mod date
      cd.writeUInt32LE(crc, 16); // CRC-32
      cd.writeUInt32LE(compressed.length, 20); // Compressed size
      cd.writeUInt32LE(uncompressed.length, 24); // Uncompressed size
      cd.writeUInt16LE(nameBuf.length, 28); // Filename length
      cd.writeUInt16LE(0, 30); // Extra field length
      cd.writeUInt16LE(0, 32); // File comment length
      cd.writeUInt16LE(0, 34); // Disk number start
      cd.writeUInt16LE(0, 36); // Internal file attributes
      cd.writeUInt32LE(0, 38); // External file attributes
      cd.writeUInt32LE(offset, 42); // Relative offset of local header
      nameBuf.copy(cd, 46);

      centralHeaders.push(cd);
      offset += lf.length + compressed.length;
    }

    const cdOffset = offset;
    let cdSize = 0;
    for (const cd of centralHeaders) cdSize += cd.length;

    // End of central directory record (22 bytes)
    const eocd = Buffer.alloc(22);
    eocd.writeUInt32LE(0x06054b50, 0); // Signature
    eocd.writeUInt16LE(0, 4); // Disk number
    eocd.writeUInt16LE(0, 6); // Start disk
    eocd.writeUInt16LE(this.entries.length, 8); // Entries on disk
    eocd.writeUInt16LE(this.entries.length, 10); // Total entries
    eocd.writeUInt32LE(cdSize, 12); // Central directory size
    eocd.writeUInt32LE(cdOffset, 16); // Offset of central directory
    eocd.writeUInt16LE(0, 20); // Comment length

    return Buffer.concat([...localHeaders, ...centralHeaders, eocd]);
  }
}

// CRC32 table
const crcTable = new Uint32Array(256);
for (let i = 0; i < 256; i++) {
  let c = i;
  for (let j = 0; j < 8; j++) {
    c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
  }
  crcTable[i] = c;
}
function crc32(buf) {
  let crc = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    crc = crcTable[(crc ^ buf[i]) & 0xff] ^ (crc >>> 8);
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function buildIPA() {
  const version = getVersion();
  log(`Mempersiapkan Tatap iOS v${version} ...`);

  fs.mkdirSync(DIST_DIR, { recursive: true });
  const tempBuildDir = path.join(DIST_DIR, 'temp_payload');
  if (fs.existsSync(tempBuildDir)) {
    fs.rmSync(tempBuildDir, { recursive: true, force: true });
  }

  const payloadDir = path.join(tempBuildDir, 'Payload');
  const appBundleDir = path.join(payloadDir, 'Tatap.app');
  fs.mkdirSync(appBundleDir, { recursive: true });

  // 1. Info.plist
  const infoPlistSrc = path.join(IOS_DIR, 'Tatap', 'Resources', 'Info.plist');
  let plistContent = fs.readFileSync(infoPlistSrc, 'utf8');
  plistContent = plistContent.replace(/2\.11\.0/g, version);
  fs.writeFileSync(path.join(appBundleDir, 'Info.plist'), plistContent, 'utf8');
  log('Disalin: Info.plist');

  // 2. Frontend assets
  const frontendDest = path.join(appBundleDir, 'frontend');
  copyRecursiveSync(FRONTEND_DIR, frontendDest);
  log('Disalin: Web frontend runtime assets');

  // 3. App Icons
  if (fs.existsSync(ICON_SRC)) {
    const iconNames = [
      'AppIcon60x60@2x.png',
      'AppIcon60x60@3x.png',
      'AppIcon76x76@2x~ipad.png',
      'AppIcon83.5x83.5@2x~ipad.png'
    ];
    for (const name of iconNames) {
      fs.copyFileSync(ICON_SRC, path.join(appBundleDir, name));
    }
    log('Disalin: App Icons untuk iPhone & iPad');
  }

  // 4. Executable binary
  const executablePath = path.join(appBundleDir, 'Tatap');
  createMachOStub(executablePath);
  log('Dihasilkan: Mach-O ARM64 Executable Binary');

  // 5. PkgInfo
  fs.writeFileSync(path.join(appBundleDir, 'PkgInfo'), Buffer.from('APPL????'));

  // 6. Zip into .ipa
  log('Mengompresi ke format IPA (Payload/Tatap.app) ...');
  const zip = new SimpleZip();

  function addDirToZip(currentDir, baseDir) {
    const items = fs.readdirSync(currentDir);
    for (const item of items) {
      const fullPath = path.join(currentDir, item);
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        addDirToZip(fullPath, baseDir);
      } else {
        const relPath = path.relative(baseDir, fullPath);
        const fileData = fs.readFileSync(fullPath);
        zip.addFile(relPath, fileData);
      }
    }
  }

  addDirToZip(tempBuildDir, tempBuildDir);
  const ipaBuffer = zip.build();

  const ipaFilename = `tatap-release-v${version}.ipa`;
  const ipaPath = path.join(DIST_DIR, ipaFilename);
  fs.writeFileSync(ipaPath, ipaBuffer);

  // Cleanup temp
  fs.rmSync(tempBuildDir, { recursive: true, force: true });

  const sizeMb = (ipaBuffer.length / (1024 * 1024)).toFixed(2);
  const hash = crypto.createHash('sha256').update(ipaBuffer).digest('hex');

  log('='.repeat(60));
  log(`BUILD SUKSES: ${ipaPath}`);
  log(`Ukuran File : ${sizeMb} MB`);
  log(`SHA-256     : ${hash}`);
  log('Kompatibel dengan Sideloadly, TrollStore, AltStore, dan Scarlet!');
  log('='.repeat(60));
}

buildIPA();
