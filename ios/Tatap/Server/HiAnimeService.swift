import Foundation
import CommonCrypto

/// Swift scraper and stream resolver for HiAnime / MegaCloud / RapidCloud.
/// Mirroring `backend/api/hianime.py`.
final class HiAnimeService {
    static let shared = HiAnimeService()
    
    private let session: URLSession
    private let baseURL = TatapConfig.hiAnimeBase
    
    // MegaCloud / RapidCloud AES Key & IV
    private let megaKey = "638d9703649479b1897c88b9011e5173e3a39e944f2b1c4161a4030616a22ae7"
    private let megaIV  = "a7491cf64b8da07c93836eb4516ff8d5"
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.httpAdditionalHeaders = [
            "User-Agent": TatapConfig.defaultUserAgent,
            "X-Requested-With": "XMLHttpRequest"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func search(keyword: String) async throws -> [[String: Any]] {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?keyword=\(encoded)") else {
            return []
        }
        
        let (data, _) = try await session.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else { return [] }
        
        // Parse search items from HTML
        var results: [[String: Any]] = []
        let pattern = #"<div class="flw-item">[\s\S]*?<a href="/watch/([^"?]+)"[^>]*>[\s\S]*?<img [^>]*data-src="([^"]+)"[^>]*alt="([^"]+)"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsHtml = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsHtml.length))
            for match in matches {
                let slug = nsHtml.substring(with: match.range(at: 1))
                let poster = nsHtml.substring(with: match.range(at: 2))
                let title = nsHtml.substring(with: match.range(at: 3))
                results.append([
                    "id": slug,
                    "title": title,
                    "poster": poster
                ])
            }
        }
        return results
    }
    
    func fetchEpisodes(animeId: String) async throws -> [[String: Any]] {
        guard let url = URL(string: "\(baseURL)/api/theme/episode/list/\(animeId)") else {
            return []
        }
        
        let (data, _) = try await session.data(from: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let html = json["html"] as? String else {
            return []
        }
        
        var episodes: [[String: Any]] = []
        let pattern = #"href="[^"]*ep=([^"&]+)"[^>]*data-number="([^"]+)"[^>]*title="([^"]*)""#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsHtml = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsHtml.length))
            for match in matches {
                let epId = nsHtml.substring(with: match.range(at: 1))
                let epNum = Int(nsHtml.substring(with: match.range(at: 2))) ?? 0
                let title = nsHtml.substring(with: match.range(at: 3))
                episodes.append([
                    "episodeId": epId,
                    "number": epNum,
                    "title": title.isEmpty ? "Episode \(epNum)" : title
                ])
            }
        }
        return episodes
    }
    
    func fetchServers(episodeId: String) async throws -> [[String: Any]] {
        guard let url = URL(string: "\(baseURL)/api/theme/episode/servers?episodeId=\(episodeId)") else {
            return []
        }
        let (data, _) = try await session.data(from: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let html = json["html"] as? String else {
            return []
        }
        
        var servers: [[String: Any]] = []
        let pattern = #"data-id="([^"]+)"[^>]*data-type="([^"]+)"[^>]*class="[^"]*server-item[^"]*"[^>]*>[\s\S]*?<a[^>]*>([^<]+)</a>"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsHtml = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsHtml.length))
            for match in matches {
                let dataId = nsHtml.substring(with: match.range(at: 1))
                let subOrDub = nsHtml.substring(with: match.range(at: 2))
                let name = nsHtml.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespacesAndNewlines)
                servers.append([
                    "id": dataId,
                    "type": subOrDub,
                    "name": name
                ])
            }
        }
        return servers
    }
    
    func resolveStream(serverId: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/ajax/v2/episode/sources?id=\(serverId)") else {
            throw NSError(domain: "HiAnimeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server URL"])
        }
        
        var request = URLRequest(url: url)
        request.setValue("https://hianime.at", forHTTPHeaderField: "Referer")
        request.setValue(TatapConfig.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let (data, _) = try await session.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let link = json["link"] as? String,
              let embedURL = URL(string: link) else {
            throw NSError(domain: "HiAnimeService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to extract embed link"])
        }
        
        // Extract stream source from embed URL (MegaCloud / RapidCloud)
        let embedHost = embedURL.host ?? "megacloud.tv"
        let sourceURLString = "https://\(embedHost)/embed-2/ajax/e-1/getSources?id=\(embedURL.lastPathComponent)"
        guard let sourceURL = URL(string: sourceURLString) else {
            throw NSError(domain: "HiAnimeService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid source URL"])
        }
        
        var sourceReq = URLRequest(url: sourceURL)
        sourceReq.setValue("https://\(embedHost)/", forHTTPHeaderField: "Referer")
        sourceReq.setValue(TatapConfig.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        sourceReq.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let (srcData, _) = try await session.data(for: sourceReq)
        guard let srcJson = try JSONSerialization.jsonObject(with: srcData, options: []) as? [String: Any] else {
            throw NSError(domain: "HiAnimeService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid source JSON"])
        }
        
        var masterM3U8 = ""
        var tracks: [[String: Any]] = []
        if let t = srcJson["tracks"] as? [[String: Any]] {
            tracks = t
        }
        
        if let sources = srcJson["sources"] as? [[String: Any]], !sources.isEmpty {
            masterM3U8 = sources[0]["file"] as? String ?? ""
        } else if let encryptedSources = srcJson["sources"] as? String {
            // Decrypt AES-CBC
            if let decrypted = decryptAES(base64Cipher: encryptedSources, hexKey: megaKey, hexIV: megaIV),
               let decData = decrypted.data(using: .utf8),
               let decArray = (try? JSONSerialization.jsonObject(with: decData, options: [])) as? [[String: Any]],
               !decArray.isEmpty {
                masterM3U8 = decArray[0]["file"] as? String ?? ""
            }
        }
        
        let proxyM3U8 = "http://127.0.0.1:\(TatapConfig.serverPort)/api/player/video?url=\(masterM3U8.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&referer=https://\(embedHost)/"
        
        return [
            "success": true,
            "master": proxyM3U8,
            "rawMaster": masterM3U8,
            "tracks": tracks,
            "referer": "https://\(embedHost)/"
        ]
    }
    
    // MARK: - AES-256-CBC Decryption via CommonCrypto
    private func decryptAES(base64Cipher: String, hexKey: String, hexIV: String) -> String? {
        guard let cipherData = Data(base64Encoded: base64Cipher),
              let keyData = hexToData(hexKey),
              let ivData = hexToData(hexIV) else {
            return nil
        }
        
        var decryptedBytes = [UInt8](repeating: 0, count: cipherData.count + kCCBlockSizeAES128)
        var numBytesDecrypted: size_t = 0
        
        let status = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            (keyData as NSData).bytes,
            keyData.count,
            (ivData as NSData).bytes,
            (cipherData as NSData).bytes,
            cipherData.count,
            &decryptedBytes,
            decryptedBytes.count,
            &numBytesDecrypted
        )
        
        guard status == kCCSuccess else { return nil }
        return String(bytes: decryptedBytes.prefix(numBytesDecrypted), encoding: .utf8)
    }
    
    private func hexToData(_ hex: String) -> Data? {
        var data = Data()
        var temp = ""
        for char in hex {
            temp.append(char)
            if temp.count == 2 {
                if let num = UInt8(temp, radix: 16) {
                    data.append(num)
                } else {
                    return nil
                }
                temp = ""
            }
        }
        return data
    }
}
