import Foundation
import SQLite3

/// Thread-safe local SQLite database for Tatap iOS.
/// Handles watch history, bookmarks, and settings using native iOS libsqlite3.
final class LocalDatabase {
    static let shared = LocalDatabase()
    
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "id.tatap.database", qos: .userInitiated)
    
    private init() {
        openDatabase()
        createTables()
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    private func getDatabaseURL() -> URL {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbDir = appSupport.appendingPathComponent("Tatap", isDirectory: true)
        try? fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true)
        return dbDir.appendingPathComponent("anime.db")
    }
    
    private func openDatabase() {
        let dbURL = getDatabaseURL()
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("[Tatap-DB] Error opening database at \(dbURL.path)")
        } else {
            // Enable WAL mode
            var errMsg: UnsafeMutablePointer<CChar>?
            sqlite3_exec(db, "PRAGMA journal_mode=WAL;", nil, nil, &errMsg)
        }
    }
    
    private func createTables() {
        let schema = """
        CREATE TABLE IF NOT EXISTS watch_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            slug TEXT,
            title TEXT,
            episode INTEGER,
            mode TEXT DEFAULT 'sub',
            progress INTEGER DEFAULT 0,
            played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            poster TEXT DEFAULT '',
            type TEXT DEFAULT ''
        );
        CREATE TABLE IF NOT EXISTS bookmarks(
            slug TEXT PRIMARY KEY,
            title TEXT,
            poster TEXT DEFAULT '',
            type TEXT DEFAULT '',
            rating TEXT DEFAULT '',
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS settings(
            key TEXT PRIMARY KEY,
            value TEXT
        );
        """
        var errMsg: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, schema, nil, nil, &errMsg) != SQLITE_OK {
            let error = String(cString: errMsg!)
            print("[Tatap-DB] Schema error: \(error)")
            sqlite3_free(errMsg)
        }
    }
    
    // MARK: - Watch History
    func getHistory() -> [[String: Any]] {
        return queue.sync {
            var items: [[String: Any]] = []
            let query = "SELECT id, slug, title, episode, mode, progress, played_at, poster, type FROM watch_history ORDER BY id DESC LIMIT 100;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    let id = sqlite3_column_int(stmt, 0)
                    let slug = String(cString: sqlite3_column_text(stmt, 1))
                    let title = String(cString: sqlite3_column_text(stmt, 2))
                    let episode = sqlite3_column_int(stmt, 3)
                    let mode = sqlite3_column_text(stmt, 4) != nil ? String(cString: sqlite3_column_text(stmt, 4)) : "sub"
                    let progress = sqlite3_column_int(stmt, 5)
                    let playedAt = sqlite3_column_text(stmt, 6) != nil ? String(cString: sqlite3_column_text(stmt, 6)) : ""
                    let poster = sqlite3_column_text(stmt, 7) != nil ? String(cString: sqlite3_column_text(stmt, 7)) : ""
                    let type = sqlite3_column_text(stmt, 8) != nil ? String(cString: sqlite3_column_text(stmt, 8)) : ""
                    
                    items.append([
                        "id": id,
                        "slug": slug,
                        "title": title,
                        "episode": episode,
                        "mode": mode,
                        "progress": progress,
                        "played_at": playedAt,
                        "poster": poster,
                        "type": type
                    ])
                }
            }
            sqlite3_finalize(stmt)
            return items
        }
    }
    
    func addHistory(slug: String, title: String, episode: Int, mode: String, progress: Int, poster: String, type: String) {
        queue.async {
            let deleteSQL = "DELETE FROM watch_history WHERE slug = ? AND episode = ?;"
            var delStmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, deleteSQL, -1, &delStmt, nil) == SQLITE_OK {
                sqlite3_bind_text(delStmt, 1, (slug as NSString).utf8String, -1, nil)
                sqlite3_bind_int(delStmt, 2, Int32(episode))
                sqlite3_step(delStmt)
            }
            sqlite3_finalize(delStmt)
            
            let insertSQL = "INSERT INTO watch_history(slug, title, episode, mode, progress, poster, type) VALUES(?, ?, ?, ?, ?, ?, ?);"
            var insStmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, insertSQL, -1, &insStmt, nil) == SQLITE_OK {
                sqlite3_bind_text(insStmt, 1, (slug as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insStmt, 2, (title as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insStmt, 3, Int32(episode))
                sqlite3_bind_text(insStmt, 4, (mode as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insStmt, 5, Int32(progress))
                sqlite3_bind_text(insStmt, 6, (poster as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insStmt, 7, (type as NSString).utf8String, -1, nil)
                sqlite3_step(insStmt)
            }
            sqlite3_finalize(insStmt)
        }
    }
    
    func clearHistory() {
        queue.async {
            sqlite3_exec(self.db, "DELETE FROM watch_history;", nil, nil, nil)
        }
    }
    
    // MARK: - Bookmarks
    func getBookmarks() -> [[String: Any]] {
        return queue.sync {
            var items: [[String: Any]] = []
            let query = "SELECT slug, title, poster, type, rating, added_at FROM bookmarks ORDER BY added_at DESC;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    let slug = String(cString: sqlite3_column_text(stmt, 0))
                    let title = String(cString: sqlite3_column_text(stmt, 1))
                    let poster = sqlite3_column_text(stmt, 2) != nil ? String(cString: sqlite3_column_text(stmt, 2)) : ""
                    let type = sqlite3_column_text(stmt, 3) != nil ? String(cString: sqlite3_column_text(stmt, 3)) : ""
                    let rating = sqlite3_column_text(stmt, 4) != nil ? String(cString: sqlite3_column_text(stmt, 4)) : ""
                    let addedAt = sqlite3_column_text(stmt, 5) != nil ? String(cString: sqlite3_column_text(stmt, 5)) : ""
                    
                    items.append([
                        "slug": slug,
                        "title": title,
                        "poster": poster,
                        "type": type,
                        "rating": rating,
                        "added_at": addedAt
                    ])
                }
            }
            sqlite3_finalize(stmt)
            return items
        }
    }
    
    func isBookmarked(slug: String) -> Bool {
        return queue.sync {
            let query = "SELECT COUNT(*) FROM bookmarks WHERE slug = ?;"
            var stmt: OpaquePointer?
            var count = 0
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (slug as NSString).utf8String, -1, nil)
                if sqlite3_step(stmt) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(stmt, 0))
                }
            }
            sqlite3_finalize(stmt)
            return count > 0
        }
    }
    
    func addBookmark(slug: String, title: String, poster: String, type: String, rating: String) {
        queue.async {
            let insertSQL = "INSERT OR REPLACE INTO bookmarks(slug, title, poster, type, rating) VALUES(?, ?, ?, ?, ?);"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (slug as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, (title as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 3, (poster as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 4, (type as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 5, (rating as NSString).utf8String, -1, nil)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }
    
    func removeBookmark(slug: String) {
        queue.async {
            let delSQL = "DELETE FROM bookmarks WHERE slug = ?;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(self.db, delSQL, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (slug as NSString).utf8String, -1, nil)
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
    }
}
