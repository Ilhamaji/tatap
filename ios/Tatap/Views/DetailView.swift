import SwiftUI

struct DetailView: View {
    let anime: Anime
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isExpandedSynopsis = false
    @State private var episodes: [Episode] = []
    @State private var isLoadingEpisodes = true
    @State private var episodesError: String? = nil
    @State private var selectedEpisode: Episode? = nil
    @State private var isBookmarked: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Banner & Poster
                ZStack(alignment: .bottomLeading) {
                    if let banner = anime.bannerURL, let url = URL(string: banner) {
                        AsyncImage(url: url) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Rectangle().fill(TatapTheme.surfaceElevated)
                            }
                        }
                        .frame(height: 200)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, TatapTheme.background],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    } else {
                        Rectangle()
                            .fill(TatapTheme.surfaceElevated)
                            .frame(height: 140)
                    }
                    
                    HStack(alignment: .bottom, spacing: 14) {
                        AsyncImage(url: URL(string: anime.coverURL ?? "")) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Rectangle().fill(TatapTheme.surface)
                            }
                        }
                        .frame(width: 100, height: 145)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(TatapTheme.border, lineWidth: 1))
                        .shadow(radius: 8)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(anime.displayTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(TatapTheme.textPrimary)
                                .lineLimit(3)
                            
                            HStack(spacing: 8) {
                                if let score = anime.averageScore, score > 0 {
                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 11))
                                        Text(String(format: "%.1f", Double(score) / 10.0))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                if let status = anime.status {
                                    Text(status.capitalized)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(TatapTheme.successGreen)
                                }
                            }
                            
                            if let studio = anime.studio {
                                Text(studio)
                                    .font(.system(size: 12))
                                    .foregroundColor(TatapTheme.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .offset(y: 20)
                }
                .padding(.bottom, 24)
                
                // Action Buttons (Play First & Bookmark)
                HStack(spacing: 12) {
                    Button(action: {
                        if let first = episodes.first {
                            selectedEpisode = first
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Mulai Nonton")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(TatapTheme.primaryCyan)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    .disabled(episodes.isEmpty)
                    .opacity(episodes.isEmpty ? 0.5 : 1.0)
                    
                    Button(action: {
                        toggleBookmark()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        Image(systemName: isBookmarked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(isBookmarked ? TatapTheme.accentPink : .white)
                            .padding(12)
                            .background(TatapTheme.surface)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(TatapTheme.border, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)
                
                // Genres Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(anime.genres, id: \.self) { genre in
                            Text(genre)
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(TatapTheme.surfaceElevated)
                                .foregroundColor(TatapTheme.primaryCyan)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Synopsis
                if let synopsis = anime.synopsis, !synopsis.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sinopsis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(TatapTheme.textPrimary)
                        
                        Text(synopsis)
                            .font(.system(size: 13))
                            .foregroundColor(TatapTheme.textSecondary)
                            .lineLimit(isExpandedSynopsis ? nil : 4)
                        
                        Button(action: {
                            withAnimation { isExpandedSynopsis.toggle() }
                        }) {
                            Text(isExpandedSynopsis ? "Tutup" : "Selengkapnya")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(TatapTheme.primaryCyan)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Episodes Grid
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Daftar Episode")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(TatapTheme.textPrimary)
                        Spacer()
                        if !episodes.isEmpty {
                            Text("\(episodes.count) Episode")
                                .font(.system(size: 12))
                                .foregroundColor(TatapTheme.textMuted)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    if isLoadingEpisodes {
                        HStack {
                            Spacer()
                            ProgressView("Mencari stream episode...")
                                .foregroundColor(TatapTheme.primaryCyan)
                                .tint(TatapTheme.primaryCyan)
                            Spacer()
                        }
                        .padding(.vertical, 30)
                    } else if let err = episodesError {
                        VStack(spacing: 6) {
                            Text("Gagal memuat episode")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.red)
                            Text(err)
                                .font(.system(size: 11))
                                .foregroundColor(TatapTheme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 8)], spacing: 8) {
                            ForEach(episodes) { ep in
                                Button(action: {
                                    selectedEpisode = ep
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }) {
                                    Text("\(ep.number)")
                                        .font(.system(size: 13, weight: .bold))
                                        .frame(height: 44)
                                        .frame(maxWidth: .infinity)
                                        .background(TatapTheme.surface)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(TatapTheme.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(TatapTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadEpisodes()
            checkBookmarkStatus()
        }
        .fullScreenCover(item: $selectedEpisode) { ep in
            PlayerView(anime: anime, episode: ep)
        }
    }
    
    private func loadEpisodes() {
        Task {
            isLoadingEpisodes = true
            episodesError = nil
            // 1. Find HiAnime slug
            guard let slug = await HiAnimeScraper.shared.findSlug(for: anime.titleRomaji) else {
                await MainActor.run {
                    self.isLoadingEpisodes = false
                    self.episodesError = "Stream belum tersedia untuk judul ini."
                }
                return
            }
            
            // 2. Fetch episodes
            do {
                let eps = try await HiAnimeScraper.shared.getEpisodes(slug: slug)
                await MainActor.run {
                    self.episodes = eps
                    self.isLoadingEpisodes = false
                }
            } catch {
                await MainActor.run {
                    self.episodesError = error.localizedDescription
                    self.isLoadingEpisodes = false
                }
            }
        }
    }
    
    private func checkBookmarkStatus() {
        isBookmarked = LocalDatabase.shared.isBookmarked(slug: "\(anime.id)")
    }
    
    private func toggleBookmark() {
        if isBookmarked {
            LocalDatabase.shared.removeBookmark(slug: "\(anime.id)")
            isBookmarked = false
        } else {
            LocalDatabase.shared.addBookmark(
                slug: "\(anime.id)",
                title: anime.displayTitle,
                poster: anime.coverURL ?? "",
                type: anime.format ?? "TV",
                rating: anime.formattedScore
            )
            isBookmarked = true
        }
    }
}
