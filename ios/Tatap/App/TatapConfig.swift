import Foundation
import UIKit
import WebKit

/// Central configuration for Tatap iOS.
enum TatapConfig {
    static let appVersion = "2.11.0"
    static let serverPort: UInt16 = 8767
    static let serverHost = "127.0.0.1"
    static var localServerURL: URL {
        URL(string: "http://\(serverHost):\(serverPort)")!
    }
    
    static let defaultUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1 TatapApp/\(appVersion)"
    static let hiAnimeBase = "https://hianime.at"
    static let aniListURL = "https://graphql.anilist.co"
}
