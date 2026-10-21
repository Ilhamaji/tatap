import Foundation

/// Native representation of an Anime title.
struct Anime: Identifiable, Hashable {
    let id: Int
    let titleRomaji: String
    let titleEnglish: String?
    let coverURL: String?
    let bannerURL: String?
    let format: String?
    let episodes: Int?
    let duration: Int?
    let averageScore: Int?
    let season: String?
    let seasonYear: Int?
    let status: String?
    let genres: [String]
    let studio: String?
    let synopsis: String?
    let nextEpisode: Int?
    let nextAiringTime: Int?
    
    var displayTitle: String {
        if let eng = titleEnglish, !eng.trimmingCharacters(in: .whitespaces).isEmpty {
            return eng
        }
        return titleRomaji
    }
    
    var formattedScore: String {
        guard let score = averageScore, score > 0 else { return "N/A" }
        return String(format: "★ %.1f", Double(score) / 10.0)
    }
    
    var formattedEpisodes: String {
        if let eps = episodes, eps > 0 {
            return "\(eps) Ep"
        }
        if let next = nextEpisode {
            return "Ep \(next - 1)+"
        }
        return "Ongoing"
    }
}
