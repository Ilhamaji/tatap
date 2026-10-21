import Foundation
import CommonCrypto

/// Native scraper and stream resolver for HiAnime / MegaCloud / RapidCloud.
final class HiAnimeScraper {
    static let shared = HiAnimeScraper()
    
    private let session: URLSession
    private let baseURL = "https://hianime.at"
    private let megaKey = "638d9703649479b1897c88b9011e5173e3a39e944f2b1c4161a4030616a22ae7"
    private let megaIV  = "a7491cf64b8da07c93836eb4516ff8d5"
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
            "X-Requested-With": "XMLHttpRequest"
        ]
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Find Anime Slug
    func findSlug(for title: String) async -> String? {
        guard let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search?keyword=\(encoded)") else {
            return nil
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else { return nil }
            
            let pattern = #"<a href="/watch/([^"?]+)"#
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let ns = html as NSString
                if let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: ns.length)) {
                    return ns.substring(with: match.range(at: 1))
                }
            }
        } catch {
            print("[HiAnime] Slug search failed: \(error)")
        }
        return nil
    }
    
    // MARK: - Fetch Episodes
    func getEpisodes(slug: String) async throws -> [Episode] {
        guard let url = URL(string: "\(baseURL)/api/theme/episode/list/\(slug)") else {
            throw NSError(domain: "HiAnime", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid episode list URL"])
        }
        
        let (data, _) = try await session.data(from: url)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let html = json["html"] as? String else {
            return []
        }
        
        var episodes: [Episode] = []
        let pattern = #"href="[^"]*ep=([^"&]+)"[^>]*data-number="([^"]+)"[^>]*title="([^"]*)""#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsHtml = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsHtml.length))
            for match in matches {
                let epId = nsHtml.substring(with: match.range(at: 1))
                let epNum = Int(nsHtml.substring(with: match.range(at: 2))) ?? 0
                let epTitle = nsHtml.substring(with: match.range(at: 3))
                episodes.append(Episode(
                    id: epId,
                    number: epNum,
                    title: epTitle.isEmpty ? "Episode \(epNum)" : epTitle
                ))
            }
        }
        return episodes
    }
    
    // MARK: - Resolve Stream
    func resolveStream(episodeId: String) async throws -> StreamSource {
        // 1. Get servers
        guard let serversURL = URL(string: "\(baseURL)/api/theme/episode/servers?episodeId=\(episodeId)") else {
            throw NSError(domain: "HiAnime", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid server URL"])
        }
        let (srvData, _) = try await session.data(from: serversURL)
        guard let srvJson = try JSONSerialization.jsonObject(with: srvData, options: []) as? [String: Any],
              let srvHtml = srvJson["html"] as? String else {
            throw NSError(domain: "HiAnime", code: -3, userInfo: [NSLocalizedDescriptionKey: "No servers available"])
        }
        
        // Find first server data-id
        var serverId: String? = nil
        let srvPattern = #"data-id="([^"]+)"[^>]*class="[^"]*server-item"#
        if let regex = try? NSRegularExpression(pattern: srvPattern, options: []) {
            let ns = srvHtml as NSString
            if let match = regex.firstMatch(in: srvHtml, options: [], range: NSRange(location: 0, length: ns.length)) {
                serverId = ns.substring(with: match.range(at: 1))
            }
        }
        
        guard let sid = serverId else {
            throw NSError(domain: "HiAnime", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to extract server ID"])
        }
        
        // 2. Fetch embed iframe source
        guard let srcURL = URL(string: "\(baseURL)/ajax/v2/episode/sources?id=\(sid)") else {
            throw NSError(domain: "HiAnime", code: -5, userInfo: [NSLocalizedDescriptionKey: "Invalid sources URL"])
        }
        var srcReq = URLRequest(url: srcURL)
        srcReq.setValue("https://hianime.at", forHTTPHeaderField: "Referer")
        
        let (sourceData, _) = try await session.data(for: srcReq)
        guard let sourceJson = try JSONSerialization.jsonObject(with: sourceData, options: []) as? [String: Any],
              let embedLink = sourceJson["link"] as? String,
              let embedURL = URL(string: embedLink) else {
            throw NSError(domain: "HiAnime", code: -6, userInfo: [NSLocalizedDescriptionKey: "Embed link not found"])
        }
        
        // 3. Extract stream configs from embed provider
        let embedHost = embedURL.host ?? "megacloud.tv"
        let getSourcesURLString = "https://\(embedHost)/embed-2/ajax/e-1/getSources?id=\(embedURL.lastPathComponent)"
        guard let getSourcesURL = URL(string: getSourcesURLString) else {
            throw NSError(domain: "HiAnime", code: -7, userInfo: [NSLocalizedDescriptionKey: "Invalid getSources URL"])
        }
        
        var getReq = URLRequest(url: getSourcesURL)
        getReq.setValue("https://\(embedHost)/", forHTTPHeaderField: "Referer")
        
        let (configData, _) = try await session.data(for: getReq)
        guard let configJson = try JSONSerialization.jsonObject(with: configData, options: []) as? [String: Any] else {
            throw NSError(domain: "HiAnime", code: -8, userInfo: [NSLocalizedDescriptionKey: "Failed to parse stream config JSON"])
        }
        
        var masterURLString: String? = nil
        var subTracks: [SubtitleTrack] = []
        
        if let tracks = configJson["tracks"] as? [[String: Any]] {
            for t in tracks {
                if let file = t["file"] as? String, let label = t["label"] as? String {
                    let kind = t["kind"] as? String ?? "captions"
                    let def = t["default"] as? Bool ?? false
                    subTracks.append(SubtitleTrack(file: file, label: label, kind: kind, isDefault: def))
                }
            }
        }
        
        if let sources = configJson["sources"] as? [[String: Any]], !sources.isEmpty {
            masterURLString = sources[0]["file"] as? String
        } else if let encryptedSources = configJson["sources"] as? String {
            if let decrypted = decryptAES(base64Cipher: encryptedSources, hexKey: megaKey, hexIV: megaIV),
               let decData = decrypted.data(using: .utf8),
               let decArray = (try? JSONSerialization.jsonObject(with: decData, options: [])) as? [[String: Any]],
               !decArray.isEmpty {
                masterURLString = decArray[0]["file"] as? String
            }
        }
        
        guard let m3u8Str = masterURLString, let m3u8URL = URL(string: m3u8Str) else {
            throw NSError(domain: "HiAnime", code: -9, userInfo: [NSLocalizedDescriptionKey: "Failed to resolve master M3U8 URL"])
        }
        
        return StreamSource(
            masterURL: m3u8URL,
            referer: "https://\(embedHost)/",
            tracks: subTracks
        )
    }
    
    // MARK: - CommonCrypto AES Decryptor
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
