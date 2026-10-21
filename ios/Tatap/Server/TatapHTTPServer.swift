import Foundation
import Network

/// Embedded lightweight asynchronous HTTP server running on 127.0.0.1:8767.
/// Serves the Tatap web frontend and handles all `/api/*` endpoints natively on iOS.
final class TatapHTTPServer {
    static let shared = TatapHTTPServer()
    
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "id.tatap.httpserver", qos: .userInitiated)
    private(set) var isRunning = false
    
    private init() {}
    
    func start() {
        guard !isRunning else { return }
        
        do {
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true
            
            guard let port = NWEndpoint.Port(rawValue: TatapConfig.serverPort) else {
                print("[Tatap-Server] Invalid port \(TatapConfig.serverPort)")
                return
            }
            
            listener = try NWListener(using: parameters, on: port)
            listener?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    print("[Tatap-Server] Running on http://127.0.0.1:\(TatapConfig.serverPort)")
                    self?.isRunning = true
                case .failed(let error):
                    print("[Tatap-Server] Listener failed with error: \(error)")
                    self?.isRunning = false
                case .cancelled:
                    print("[Tatap-Server] Listener cancelled")
                    self?.isRunning = false
                default:
                    break
                }
            }
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            
            listener?.start(queue: queue)
        } catch {
            print("[Tatap-Server] Failed to start listener: \(error)")
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
        isRunning = false
    }
    
    // MARK: - Connection Handling
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        receiveRequest(connection)
    }
    
    private func receiveRequest(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, context, isComplete, error in
            guard let self = self, let data = data, !data.isEmpty else {
                connection.cancel()
                return
            }
            
            guard let requestString = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }
            
            Task {
                await self.routeRequest(requestString: requestString, connection: connection)
            }
        }
    }
    
    // MARK: - HTTP Routing
    
    private func routeRequest(requestString: String, connection: NWConnection) async {
        let lines = requestString.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            sendResponse(connection: connection, statusCode: 400, headers: [:], body: Data())
            return
        }
        
        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            sendResponse(connection: connection, statusCode: 400, headers: [:], body: Data())
            return
        }
        
        let method = parts[0]
        let rawPath = parts[1]
        
        guard let urlComponents = URLComponents(string: "http://127.0.0.1\(rawPath)") else {
            sendResponse(connection: connection, statusCode: 400, headers: [:], body: Data())
            return
        }
        
        let path = urlComponents.path
        let queryItems = urlComponents.queryItems ?? []
        
        // Parse request body for POST/PUT requests
        var bodyData = Data()
        if let emptyLineIndex = lines.firstIndex(of: "") {
            let bodyString = lines.suffix(from: emptyLineIndex + 1).joined(separator: "\r\n")
            bodyData = bodyString.data(using: .utf8) ?? Data()
        }
        
        // Handle CORS preflight
        if method == "OPTIONS" {
            let corsHeaders = [
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Range"
            ]
            sendResponse(connection: connection, statusCode: 200, headers: corsHeaders, body: Data())
            return
        }
        
        // Route API Requests
        if path.hasPrefix("/api/") {
            await handleAPI(path: path, method: method, queryItems: queryItems, body: bodyData, connection: connection)
            return
        }
        
        // Serve Static Frontend Assets
        serveStatic(path: path, connection: connection)
    }
    
    // MARK: - API Handlers
    
    private func handleAPI(path: String, method: String, queryItems: [URLQueryItem], body: Data, connection: NWConnection) async {
        func queryVal(_ name: String) -> String? {
            queryItems.first(where: { $0.name == name })?.value
        }
        
        let defaultHeaders = [
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Cache-Control": "no-cache"
        ]
        
        if path == "/api/ping" {
            let payload = ["success": true, "data": ["status": "running"]] as [String: Any]
            sendJSON(connection: connection, json: payload)
            return
        }
        
        if path == "/api/version" {
            let payload = ["success": true, "data": ["version": TatapConfig.appVersion]] as [String: Any]
            sendJSON(connection: connection, json: payload)
            return
        }
        
        if path == "/api/seasonal" {
            let which = queryVal("which") ?? "season"
            let page = Int(queryVal("page") ?? "1") ?? 1
            do {
                if which == "airing" {
                    let result = try await AniListService.shared.fetchAiring(page: page)
                    sendJSON(connection: connection, json: ["success": true, "data": result])
                } else {
                    let season = queryVal("season")
                    let year = Int(queryVal("year") ?? "0")
                    let result = try await AniListService.shared.fetchSeasonal(season: season, year: year, page: page)
                    sendJSON(connection: connection, json: ["success": true, "data": result])
                }
            } catch {
                sendJSON(connection: connection, json: ["success": false, "error": error.localizedDescription])
            }
            return
        }
        
        if path == "/api/schedule" {
            let start = Int(queryVal("start") ?? "0") ?? Int(Date().timeIntervalSince1970)
            let end = Int(queryVal("end") ?? "0") ?? (start + 86400 * 7)
            do {
                let result = try await AniListService.shared.fetchSchedule(start: start, end: end)
                sendJSON(connection: connection, json: ["success": true, "data": result])
            } catch {
                sendJSON(connection: connection, json: ["success": false, "error": error.localizedDescription])
            }
            return
        }
        
        if path == "/api/search" {
            let q = queryVal("q") ?? ""
            let page = Int(queryVal("page") ?? "1") ?? 1
            do {
                let result = try await AniListService.shared.searchAnime(keyword: q, page: page)
                sendJSON(connection: connection, json: ["success": true, "data": result])
            } catch {
                sendJSON(connection: connection, json: ["success": false, "error": error.localizedDescription])
            }
            return
        }
        
        if path.contains("/episodes") {
            let slug = path.replacingOccurrences(of: "/api/anime/", with: "").replacingOccurrences(of: "/episodes", with: "")
            do {
                let episodes = try await HiAnimeService.shared.fetchEpisodes(animeId: slug)
                sendJSON(connection: connection, json: ["success": true, "data": episodes])
            } catch {
                sendJSON(connection: connection, json: ["success": false, "error": error.localizedDescription])
            }
            return
        }
        
        if path == "/api/stream/resolve" {
            let serverId = queryVal("server_id") ?? ""
            do {
                let stream = try await HiAnimeService.shared.resolveStream(serverId: serverId)
                sendJSON(connection: connection, json: ["success": true, "data": stream])
            } catch {
                sendJSON(connection: connection, json: ["success": false, "error": error.localizedDescription])
            }
            return
        }
        
        if path == "/api/player/video" {
            guard let targetURL = queryVal("url"), !targetURL.isEmpty else {
                sendResponse(connection: connection, statusCode: 400, headers: defaultHeaders, body: Data("Missing url".utf8))
                return
            }
            let referer = queryVal("referer")
            do {
                let (data, mimeType) = try await StreamProxy.shared.proxyRequest(targetURLString: targetURL, referer: referer)
                let headers = [
                    "Content-Type": mimeType,
                    "Access-Control-Allow-Origin": "*",
                    "Cache-Control": "public, max-age=3600"
                ]
                sendResponse(connection: connection, statusCode: 200, headers: headers, body: data)
            } catch {
                sendResponse(connection: connection, statusCode: 502, headers: defaultHeaders, body: Data("Proxy error: \(error.localizedDescription)".utf8))
            }
            return
        }
        
        // History & Bookmarks via LocalDatabase
        if path == "/api/history" {
            if method == "GET" {
                let history = LocalDatabase.shared.getHistory()
                sendJSON(connection: connection, json: ["success": true, "data": history])
            } else if method == "POST" {
                if let bodyObj = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any] {
                    let slug = bodyObj["slug"] as? String ?? ""
                    let title = bodyObj["title"] as? String ?? ""
                    let episode = bodyObj["episode"] as? Int ?? 1
                    let mode = bodyObj["mode"] as? String ?? "sub"
                    let progress = bodyObj["progress"] as? Int ?? 0
                    let poster = bodyObj["poster"] as? String ?? ""
                    let type = bodyObj["type"] as? String ?? ""
                    LocalDatabase.shared.addHistory(slug: slug, title: title, episode: episode, mode: mode, progress: progress, poster: poster, type: type)
                    sendJSON(connection: connection, json: ["success": true])
                }
            } else if method == "DELETE" {
                LocalDatabase.shared.clearHistory()
                sendJSON(connection: connection, json: ["success": true])
            }
            return
        }
        
        if path == "/api/bookmarks" {
            if method == "GET" {
                let bookmarks = LocalDatabase.shared.getBookmarks()
                sendJSON(connection: connection, json: ["success": true, "data": bookmarks])
            } else if method == "POST" {
                if let bodyObj = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any] {
                    let slug = bodyObj["slug"] as? String ?? ""
                    let title = bodyObj["title"] as? String ?? ""
                    let poster = bodyObj["poster"] as? String ?? ""
                    let type = bodyObj["type"] as? String ?? ""
                    let rating = bodyObj["rating"] as? String ?? ""
                    LocalDatabase.shared.addBookmark(slug: slug, title: title, poster: poster, type: type, rating: rating)
                    sendJSON(connection: connection, json: ["success": true])
                }
            }
            return
        }
        
        // Default 404 for unknown API
        sendJSON(connection: connection, json: ["success": false, "error": "Endpoint not found: \(path)"])
    }
    
    // MARK: - Static Files
    
    private func serveStatic(path: String, connection: NWConnection) {
        let cleanPath = (path == "/" || path.isEmpty) ? "index.html" : String(path.dropFirst())
        
        // Check in Bundle
        var fileURL: URL?
        if let bundleResource = Bundle.main.url(forResource: cleanPath, withExtension: nil, subdirectory: "frontend") {
            fileURL = bundleResource
        } else if let bundleRoot = Bundle.main.url(forResource: cleanPath, withExtension: nil) {
            fileURL = bundleRoot
        }
        
        guard let url = fileURL, let data = try? Data(contentsOf: url) else {
            // Fallback: Return index.html for SPA routing
            if let indexURL = Bundle.main.url(forResource: "index.html", withExtension: nil, subdirectory: "frontend"),
               let indexData = try? Data(contentsOf: indexURL) {
                sendResponse(connection: connection, statusCode: 200, headers: ["Content-Type": "text/html; charset=utf-8"], body: indexData)
                return
            }
            sendResponse(connection: connection, statusCode: 404, headers: ["Content-Type": "text/plain"], body: Data("File not found".utf8))
            return
        }
        
        let mimeType = getMimeType(for: url.pathExtension)
        sendResponse(connection: connection, statusCode: 200, headers: ["Content-Type": mimeType], body: data)
    }
    
    private func getMimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "js": return "application/javascript; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "svg": return "image/svg+xml"
        case "ico": return "image/x-icon"
        case "json": return "application/json"
        case "woff2": return "font/woff2"
        case "vtt": return "text/vtt"
        default: return "application/octet-stream"
        }
    }
    
    // MARK: - Helpers
    
    private func sendJSON(connection: NWConnection, json: [String: Any]) {
        let data = (try? JSONSerialization.data(withJSONObject: json, options: [])) ?? Data()
        let headers = [
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Cache-Control": "no-cache"
        ]
        sendResponse(connection: connection, statusCode: 200, headers: headers, body: data)
    }
    
    private func sendResponse(connection: NWConnection, statusCode: Int, headers: [String: String], body: Data) {
        let statusText: String
        switch statusCode {
        case 200: statusText = "OK"
        case 400: statusText = "Bad Request"
        case 404: statusText = "Not Found"
        case 500: statusText = "Internal Server Error"
        case 502: statusText = "Bad Gateway"
        default: statusText = "Status \(statusCode)"
        }
        
        var headerLines = ["HTTP/1.1 \(statusCode) \(statusText)"]
        for (k, v) in headers {
            headerLines.append("\(k): \(v)")
        }
        headerLines.append("Content-Length: \(body.count)")
        headerLines.append("Connection: close")
        
        let headerData = (headerLines.joined(separator: "\r\n") + "\r\n\r\n").data(using: .utf8) ?? Data()
        var fullData = headerData
        fullData.append(body)
        
        connection.send(content: fullData, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}
