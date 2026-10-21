import Foundation

/// Native Swift GraphQL client for AniList.
final class AniListClient {
    static let shared = AniListClient()
    
    private let session: URLSession
    private let endpoint = URL(string: "https://graphql.anilist.co")!
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        config.httpAdditionalHeaders = [
            "User-Agent": "Tatap-iOS/2.11.0",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic GraphQL Request
    func query(queryString: String, variables: [String: Any]) async throws -> [String: Any] {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        let payload: [String: Any] = ["query": queryString, "variables": variables]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "AniListClient", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "AniList HTTP error"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let dataObj = json["data"] as? [String: Any] else {
            throw NSError(domain: "AniListClient", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid AniList response"])
        }
        return dataObj
    }
    
    // MARK: - Seasonal Anime
    func getSeasonal(season: String? = nil, year: Int? = nil, page: Int = 1) async throws -> [Anime] {
        let q = """
        query ($season: MediaSeason, $year: Int, $page: Int) {
          Page(page: $page, perPage: 30) {
            media(season: $season, seasonYear: $year, type: ANIME, sort: POPULARITY_DESC, isAdult: false) {
              id
              title { romaji english }
              coverImage { large }
              bannerImage
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              status
              genres
              description(asHtml: false)
              studios(isMain: true) { nodes { name } }
              nextAiringEpisode { episode airingAt timeUntilAiring }
            }
          }
        }
        """
        var vars: [String: Any] = ["page": page]
        if let s = season { vars["season"] = s.uppercased() }
        if let y = year, y > 0 { vars["year"] = y }
        
        let data = try await query(queryString: q, variables: vars)
        return parseMediaList(data: data)
    }
    
    // MARK: - Currently Airing Anime
    func getAiring(page: Int = 1) async throws -> [Anime] {
        let q = """
        query ($page: Int) {
          Page(page: $page, perPage: 30) {
            media(status: RELEASING, type: ANIME, sort: POPULARITY_DESC, isAdult: false) {
              id
              title { romaji english }
              coverImage { large }
              bannerImage
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              status
              genres
              description(asHtml: false)
              studios(isMain: true) { nodes { name } }
              nextAiringEpisode { episode airingAt timeUntilAiring }
            }
          }
        }
        """
        let data = try await query(queryString: q, variables: ["page": page])
        return parseMediaList(data: data)
    }
    
    // MARK: - Catalog with Filters
    func getCatalog(sort: String = "POPULARITY_DESC", genre: String? = nil, year: Int? = nil, page: Int = 1) async throws -> [Anime] {
        let q = """
        query ($sort: [MediaSort], $genre: String, $year: Int, $page: Int) {
          Page(page: $page, perPage: 30) {
            media(sort: $sort, genre: $genre, seasonYear: $year, type: ANIME, isAdult: false) {
              id
              title { romaji english }
              coverImage { large }
              bannerImage
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              status
              genres
              description(asHtml: false)
              studios(isMain: true) { nodes { name } }
              nextAiringEpisode { episode airingAt timeUntilAiring }
            }
          }
        }
        """
        var vars: [String: Any] = ["sort": [sort], "page": page]
        if let g = genre, !g.isEmpty { vars["genre"] = g }
        if let y = year, y > 0 { vars["year"] = y }
        
        let data = try await query(queryString: q, variables: vars)
        return parseMediaList(data: data)
    }
    
    // MARK: - Search
    func search(keyword: String, page: Int = 1) async throws -> [Anime] {
        let q = """
        query ($search: String, $page: Int) {
          Page(page: $page, perPage: 30) {
            media(search: $search, type: ANIME, sort: SEARCH_MATCH, isAdult: false) {
              id
              title { romaji english }
              coverImage { large }
              bannerImage
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              status
              genres
              description(asHtml: false)
              studios(isMain: true) { nodes { name } }
              nextAiringEpisode { episode airingAt timeUntilAiring }
            }
          }
        }
        """
        let data = try await query(queryString: q, variables: ["search": keyword, "page": page])
        return parseMediaList(data: data)
    }
    
    // MARK: - Parser Helper
    private func parseMediaList(data: [String: Any]) -> [Anime] {
        guard let page = data["Page"] as? [String: Any],
              let mediaList = page["media"] as? [[String: Any]] else {
            return []
        }
        
        return mediaList.compactMap { m -> Anime? in
            guard let id = m["id"] as? Int else { return nil }
            let titleObj = m["title"] as? [String: Any]
            let titleRomaji = titleObj?["romaji"] as? String ?? "Anime #\(id)"
            let titleEnglish = titleObj?["english"] as? String
            
            let coverObj = m["coverImage"] as? [String: Any]
            let cover = coverObj?["large"] as? String
            let banner = m["bannerImage"] as? String
            
            let format = m["format"] as? String
            let episodes = m["episodes"] as? Int
            let duration = m["duration"] as? Int
            let score = m["averageScore"] as? Int
            let season = m["season"] as? String
            let seasonYear = m["seasonYear"] as? Int
            let status = m["status"] as? String
            let genres = m["genres"] as? [String] ?? []
            let synopsis = cleanHTML(m["description"] as? String)
            
            var studioName: String? = nil
            if let studios = m["studios"] as? [String: Any],
               let nodes = studios["nodes"] as? [[String: Any]],
               let first = nodes.first {
                studioName = first["name"] as? String
            }
            
            var nextEp: Int? = nil
            var nextTime: Int? = nil
            if let nextObj = m["nextAiringEpisode"] as? [String: Any] {
                nextEp = nextObj["episode"] as? Int
                nextTime = nextObj["airingAt"] as? Int
            }
            
            return Anime(
                id: id,
                titleRomaji: titleRomaji,
                titleEnglish: titleEnglish,
                coverURL: cover,
                bannerURL: banner,
                format: format,
                episodes: episodes,
                duration: duration,
                averageScore: score,
                season: season,
                seasonYear: seasonYear,
                status: status,
                genres: genres,
                studio: studioName,
                synopsis: synopsis,
                nextEpisode: nextEp,
                nextAiringTime: nextTime
            )
        }
    }
    
    private func cleanHTML(_ html: String?) -> String? {
        guard let s = html else { return nil }
        return s
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "<br/>", with: "\n")
            .replacingOccurrences(of: "<br />", with: "\n")
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "\n\n")
            .replacingOccurrences(of: "<i>", with: "")
            .replacingOccurrences(of: "</i>", with: "")
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
