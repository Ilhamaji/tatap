import Foundation

/// Proxy and rewriter for M3U8 playlists and video segments.
/// Mirroring the `/api/player/video` endpoint from `backend/main.py`.
final class StreamProxy {
    static let shared = StreamProxy()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        self.session = URLSession(configuration: config)
    }
    
    func proxyRequest(targetURLString: String, referer: String?) async throws -> (Data, String) {
        guard let url = URL(string: targetURLString) else {
            throw NSError(domain: "StreamProxy", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid target URL"])
        }
        
        var request = URLRequest(url: url)
        if let ref = referer, !ref.isEmpty {
            request.setValue(ref, forHTTPHeaderField: "Referer")
            request.setValue(ref, forHTTPHeaderField: "Origin")
        }
        request.setValue(TatapConfig.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        let mimeType = response.mimeType ?? (targetURLString.contains(".m3u8") ? "application/vnd.apple.mpegurl" : "video/MP2T")
        
        // If it's an M3U8 playlist, rewrite the lines
        if targetURLString.contains(".m3u8") || mimeType.contains("mpegurl") {
            if let content = String(data: data, encoding: .utf8) {
                let rewritten = rewriteM3U8(content: content, baseURL: url, referer: referer)
                return (rewritten.data(using: .utf8) ?? data, "application/vnd.apple.mpegurl")
            }
        }
        
        return (data, mimeType)
    }
    
    private func rewriteM3U8(content: String, baseURL: URL, referer: String?) -> String {
        let lines = content.components(separatedBy: "\n")
        var newLines: [String] = []
        
        let proxyBase = "http://127.0.0.1:\(TatapConfig.serverPort)/api/player/video?url="
        let refParam = referer != nil ? "&referer=\(referer!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                newLines.append(line)
                continue
            }
            
            // Check for URI in tags like #EXT-X-KEY or #EXT-X-MEDIA
            if trimmed.hasPrefix("#EXT") {
                if trimmed.contains("URI=\"") {
                    let pattern = #"URI="([^"]+)""#
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                        let nsLine = trimmed as NSString
                        let matches = regex.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsLine.length))
                        var modified = trimmed
                        for match in matches.reversed() {
                            let originalURI = nsLine.substring(with: match.range(at: 1))
                            let absoluteURL = URL(string: originalURI, relativeTo: baseURL)?.absoluteString ?? originalURI
                            let proxied = "\(proxyBase)\(absoluteURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")\(refParam)"
                            if let swiftRange = Range(match.range(at: 1), in: modified) {
                                modified.replaceSubrange(swiftRange, with: proxied)
                            }
                        }
                        newLines.append(modified)
                        continue
                    }
                }
                newLines.append(line)
                continue
            }
            
            // Ordinary segment or sub-playlist line
            if !trimmed.hasPrefix("#") {
                let absoluteURL = URL(string: trimmed, relativeTo: baseURL)?.absoluteString ?? trimmed
                let proxied = "\(proxyBase)\(absoluteURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")\(refParam)"
                newLines.append(proxied)
            } else {
                newLines.append(line)
            }
        }
        
        return newLines.joined(separator: "\n")
    }
}
