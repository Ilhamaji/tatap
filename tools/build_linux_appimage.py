#!/usr/bin/env python3
"""
Tatap Linux AppImage Builder
----------------------------
Script ini mengotomatiskan pembuatan paket portabel AppImage untuk Linux:
1. Mengunduh official Python Standalone runtime x86_64 (python-build-standalone)
2. Mengunduh official appimagetool (AppImageKit)
3. Mengekstrak dan mengonfigurasi AppDir (dist/Tatap.AppDir)
4. Memasang dependensi Python Linux via pip standalone (fastapi, uvicorn, curl_cffi, dll.)
5. Menyalin backend, frontend, icon, tatap.desktop, dan AppRun
6. Membungkus menjadi executable mandiri: dist/Tatap-x86_64.AppImage
"""

import os
import sys
import shutil
import urllib.request
import tarfile
import subprocess
from PIL import Image

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIST_DIR = os.path.join(ROOT_DIR, "dist")
APPDIR = os.path.join(DIST_DIR, "Tatap.AppDir")
CACHE_DIR = os.path.join(ROOT_DIR, ".build_cache")

PYTHON_STANDALONE_URL = (
    "https://github.com/indygreg/python-build-standalone/releases/download/"
    "20240415/cpython-3.11.9+20240415-x86_64-unknown-linux-gnu-install_only.tar.gz"
)
PYTHON_TAR_NAME = "cpython-3.11.9-linux-x86_64-install_only.tar.gz"

APPIMAGETOOL_URL = (
    "https://github.com/AppImage/appimagetool/releases/download/continuous/"
    "appimagetool-x86_64.AppImage"
)
APPIMAGETOOL_NAME = "appimagetool-x86_64.AppImage"

OUTPUT_APPIMAGE = os.path.join(DIST_DIR, "Tatap-x86_64.AppImage")


def log(msg):
    print(f"\n[BUILD-APPIMAGE] {msg}")


def download_file(url, target_path, retries=3):
    if os.path.exists(target_path) and os.path.getsize(target_path) > 0:
        log(f"Menggunakan file cache: {os.path.basename(target_path)}")
        return
    log(f"Mengunduh {url} ...")
    os.makedirs(os.path.dirname(target_path), exist_ok=True)

    if shutil.which("curl"):
        for attempt in range(1, retries + 1):
            try:
                subprocess.run(
                    ["curl", "-sSL", "--retry", "3", "--retry-connrefused", "-o", target_path, url],
                    check=True
                )
                if os.path.exists(target_path) and os.path.getsize(target_path) > 0:
                    log(f"Selesai mengunduh {os.path.basename(target_path)} via curl")
                    return
            except subprocess.CalledProcessError:
                if attempt == retries:
                    raise
                import time
                time.sleep(2)

    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=60) as resp, open(target_path, "wb") as f:
                shutil.copyfileobj(resp, f)
            log(f"Selesai mengunduh {os.path.basename(target_path)}")
            return
        except Exception as e:
            if attempt == retries:
                raise e
            import time
            time.sleep(2)


def setup_standalone_python(usr_dir):
    tar_path = os.path.join(CACHE_DIR, PYTHON_TAR_NAME)
    download_file(PYTHON_STANDALONE_URL, tar_path)

    log(f"Mengekstrak Python standalone ke {usr_dir} ...")
    os.makedirs(usr_dir, exist_ok=True)
    temp_extract = os.path.join(CACHE_DIR, "py_temp")
    if os.path.exists(temp_extract):
        shutil.rmtree(temp_extract)
    os.makedirs(temp_extract, exist_ok=True)

    with tarfile.open(tar_path, "r:gz") as tar:
        tar.extractall(path=temp_extract)

    extracted_python = os.path.join(temp_extract, "python")
    if os.path.exists(extracted_python):
        for item in os.listdir(extracted_python):
            src_item = os.path.join(extracted_python, item)
            dst_item = os.path.join(usr_dir, item)
            if os.path.exists(dst_item):
                if os.path.isdir(dst_item):
                    shutil.rmtree(dst_item)
                else:
                    os.remove(dst_item)
            shutil.move(src_item, dst_item)
    shutil.rmtree(temp_extract, ignore_errors=True)

    py_bin = os.path.join(usr_dir, "bin", "python3")
    if not os.path.exists(py_bin):
        raise RuntimeError(f"Python binary tidak ditemukan di {py_bin}")
    os.chmod(py_bin, 0o755)
    log(f"Python standalone siap di {py_bin}")


def install_linux_dependencies(usr_dir):
    py_bin = os.path.join(usr_dir, "bin", "python3")
    req_file = os.path.join(ROOT_DIR, "requirements.txt")

    log("Memasang dependensi Python Linux via standalone pip...")
    cmd = [
        py_bin, "-m", "pip", "install", "--no-warn-script-location",
        "--upgrade", "pip", "wheel", "setuptools"
    ]
    subprocess.run(cmd, check=True)

    cmd_install = [
        py_bin, "-m", "pip", "install", "--no-warn-script-location",
        "-r", req_file
    ]
    subprocess.run(cmd_install, check=True)
    log("Dependensi Python berhasil dipasang ke runtime AppDir.")


def prepare_icons(appdir):
    ico_path = os.path.join(ROOT_DIR, "launcher", "icon.ico")
    png_path = os.path.join(appdir, "tatap.png")
    dir_icon = os.path.join(appdir, ".DirIcon")

    log("Mengekstrak ikon 256x256 untuk AppImage...")
    try:
        im = Image.open(ico_path)
        # Ambil frame resolusi terbesar
        best_size = (0, 0)
        best_frame = 0
        for frame in range(getattr(im, "n_frames", 1)):
            im.seek(frame)
            if im.size[0] > best_size[0]:
                best_size = im.size
                best_frame = frame
        im.seek(best_frame)
        im.save(png_path, format="PNG")
        shutil.copy2(png_path, dir_icon)
        log(f"Ikon berhasil dibuat: {png_path} ({best_size[0]}x{best_size[1]})")
    except Exception as e:
        log(f"Gagal mengekstrak ikon: {e}, membuat fallback ikon...")
        im = Image.new("RGBA", (256, 256), color=(40, 44, 52, 255))
        im.save(png_path, format="PNG")
        shutil.copy2(png_path, dir_icon)


def copy_project_files(appdir):
    log("Menyalin kode aplikasi dan aset frontend...")
    # Copy backend
    backend_dst = os.path.join(appdir, "backend")
    if os.path.exists(backend_dst):
        shutil.rmtree(backend_dst)
    shutil.copytree(
        os.path.join(ROOT_DIR, "backend"),
        backend_dst,
        ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "*.db", "anime.db*")
    )

    # Copy frontend
    frontend_dst = os.path.join(appdir, "frontend")
    if os.path.exists(frontend_dst):
        shutil.rmtree(frontend_dst)
    shutil.copytree(os.path.join(ROOT_DIR, "frontend"), frontend_dst)

    # Copy AppRun & desktop entry
    apprun_src = os.path.join(ROOT_DIR, "linux", "AppRun")
    apprun_dst = os.path.join(appdir, "AppRun")
    shutil.copy2(apprun_src, apprun_dst)
    os.chmod(apprun_dst, 0o755)

    desktop_src = os.path.join(ROOT_DIR, "linux", "tatap.desktop")
    desktop_dst = os.path.join(appdir, "tatap.desktop")
    shutil.copy2(desktop_src, desktop_dst)
    os.chmod(desktop_dst, 0o644)


def build_appimage():
    tool_path = os.path.join(CACHE_DIR, APPIMAGETOOL_NAME)
    download_file(APPIMAGETOOL_URL, tool_path)
    os.chmod(tool_path, 0o755)

    if os.path.exists(OUTPUT_APPIMAGE):
        os.remove(OUTPUT_APPIMAGE)

    log(f"Membuat package AppImage: {OUTPUT_APPIMAGE} ...")
    env = os.environ.copy()
    env["ARCH"] = "x86_64"

    cmd = [tool_path, "--appimage-extract-and-run", APPDIR, OUTPUT_APPIMAGE]
    res = subprocess.run(cmd, env=env)
    if res.returncode != 0:
        # Coba jalankan langsung jika tanpa extract-and-run
        cmd_direct = [tool_path, APPDIR, OUTPUT_APPIMAGE]
        subprocess.run(cmd_direct, env=env, check=True)

    if not os.path.exists(OUTPUT_APPIMAGE):
        raise RuntimeError("Gagal menghasilkan file AppImage.")

    os.chmod(OUTPUT_APPIMAGE, 0o755)
    size_mb = os.path.getsize(OUTPUT_APPIMAGE) / (1024 * 1024)
    log(f"AppImage berhasil dibuat: {OUTPUT_APPIMAGE} ({size_mb:.2f} MB)")


def main():
    log("=== Memulai Build Tatap Linux AppImage ===")
    os.makedirs(DIST_DIR, exist_ok=True)
    os.makedirs(CACHE_DIR, exist_ok=True)

    usr_dir = os.path.join(APPDIR, "usr")

    # 1. Setup standalone python runtime
    setup_standalone_python(usr_dir)

    # 2. Pasang dependencies
    install_linux_dependencies(usr_dir)

    # 3. Siapkan icon
    prepare_icons(APPDIR)

    # 4. Salin project files & launcher
    copy_project_files(APPDIR)

    # 5. Build AppImage
    build_appimage()

    log("=== Build AppImage Selesai dengan Sukses! ===")
    print(f"""
File AppImage siap digunakan:
-> {OUTPUT_APPIMAGE}

Cara menjalankan:
  chmod +x {OUTPUT_APPIMAGE}
  {OUTPUT_APPIMAGE}
""")


if __name__ == "__main__":
    main()
