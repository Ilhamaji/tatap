import Foundation

/// Swift client for AniList GraphQL API.
/// Mirroring `backend/api/anilist.py`.
final class AniListService {
    static let shared = AniListService()
    
    private let session: URLSession
    private let endpoint = URL(string: TatapConfig.aniListURL)!
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        config.httpAdditionalHeaders = [
            "User-Agent": TatapConfig.defaultUserAgent,
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func executeQuery(query: String, variables: [String: Any]) async throws -> [String: Any] {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        let payload: [String: Any] = [
            "query": query,
            "variables": variables
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "AniListService", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "AniList API HTTP error"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let dataObj = json["data"] as? [String: Any] else {
            throw NSError(domain: "AniListService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response from AniList"])
        }
        
        return dataObj
    }
    
    func fetchSeasonal(season: String?, year: Int?, page: Int = 1, perPage: Int = 30) async throws -> [String: Any] {
        let query = """
        query ($season: MediaSeason, $year: Int, $page: Int, $perPage: Int) {
          Page(page: $page, perPage: $perPage) {
            pageInfo { total perPage currentPage lastPage hasNextPage }
            media(season: $season, seasonYear: $year, type: ANIME, sort: POPULARITY_DESC) {
              id
              status
              title { romaji english }
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              genres
              coverImage { large medium }
              description(asHtml: false)
              nextAiringEpisode {
                episode
                airingAt
                timeUntilAiring
              }
            }
          }
        }
        """
        var vars: [String: Any] = ["page": page, "perPage": perPage]
        if let s = season, !s.isEmpty { vars["season"] = s.uppercased() }
        if let y = year, y > 0 { vars["year"] = y }
        return try await executeQuery(query: query, variables: vars)
    }
    
    func fetchAiring(page: Int = 1, perPage: Int = 30) async throws -> [String: Any] {
        let query = """
        query ($page: Int, $perPage: Int) {
          Page(page: $page, perPage: $perPage) {
            pageInfo { total perPage currentPage lastPage hasNextPage }
            media(status: RELEASING, type: ANIME, sort: POPULARITY_DESC) {
              id
              status
              title { romaji english }
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              genres
              coverImage { large medium }
              description(asHtml: false)
              nextAiringEpisode {
                episode
                airingAt
                timeUntilAiring
              }
            }
          }
        }
        """
        return try await executeQuery(query: query, variables: ["page": page, "perPage": perPage])
    }
    
    func searchAnime(keyword: String, page: Int = 1, perPage: Int = 30) async throws -> [String: Any] {
        let query = """
        query ($search: String, $page: Int, $perPage: Int) {
          Page(page: $page, perPage: $perPage) {
            pageInfo { total perPage currentPage lastPage hasNextPage }
            media(search: $search, type: ANIME, sort: SEARCH_MATCH) {
              id
              status
              title { romaji english }
              format
              episodes
              duration
              averageScore
              season
              seasonYear
              genres
              coverImage { large medium }
              description(asHtml: false)
            }
          }
        }
        """
        return try await executeQuery(query: query, variables: ["search": keyword, "page": page, "perPage": perPage])
    }
    
    func fetchSchedule(start: Int, end: Int) async throws -> [String: Any] {
        let query = """
        query ($start: Int, $end: Int) {
          Page(page: 1, perPage: 50) {
            airingSchedules(airingAt_greater: $start, airingAt_lesser: $end, sort: TIME) {
              id
              airingAt
              timeUntilAiring
              episode
              media {
                id
                title { romaji english }
                coverImage { large medium }
                format
                averageScore
              }
            }
          }
        }
        """
        return try await executeQuery(query: query, variables: ["start": start, "end": end])
    }
}
