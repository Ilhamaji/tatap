import Foundation

struct Episode: Identifiable, Hashable {
    let id: String
    let number: Int
    let title: String
}

struct SubtitleTrack: Identifiable, Hashable {
    let id = UUID()
    let file: String
    let label: String
    let kind: String
    let isDefault: Bool
}

struct StreamSource: Hashable {
    let masterURL: URL
    let referer: String
    let tracks: [SubtitleTrack]
}

enum NavigationTab: String, CaseIterable, Identifiable {
    case musim = "Musim Ini"
    case airing = "Sedang Tayang"
    case jadwal = "Jadwal"
    case katalog = "Katalog"
    case riwayat = "Riwayat"
    case favorit = "Favorit"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .musim: return "sparkles"
        case .airing: return "play.circle.fill"
        case .jadwal: return "calendar"
        case .katalog: return "square.grid.2x2"
        case .riwayat: return "clock.arrow.circlepath"
        case .favorit: return "heart.fill"
        }
    }
}
