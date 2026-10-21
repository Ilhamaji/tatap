import SwiftUI

struct HomeView: View {
    @State private var selectedTab: NavigationTab = .musim
    @State private var searchQuery: String = ""
    @State private var animeList: [Anime] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var currentPage: Int = 1
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                TatapTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(TatapTheme.primaryCyan)
                                .frame(width: 8, height: 8)
                            Text("TATAP")
                                .font(.system(size: 20, weight: .black, design: .monospaced))
                                .tracking(3)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("v2.11.0")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(TatapTheme.primaryCyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(TatapTheme.surface)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    
                    // Unified Search Bar
                    SearchBarView(
                        text: $searchQuery,
                        onCommit: {
                            performSearch()
                        },
                        onClear: {
                            loadCurrentTab()
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    
                    // Horizontal Tab Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(NavigationTab.allCases) { tab in
                                Button(action: {
                                    if selectedTab != tab {
                                        selectedTab = tab
                                        searchQuery = ""
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        loadCurrentTab()
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: tab.iconName)
                                            .font(.system(size: 11))
                                        Text(tab.rawValue)
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(selectedTab == tab ? TatapTheme.primaryCyan : TatapTheme.surface)
                                    .foregroundColor(selectedTab == tab ? .black : TatapTheme.textSecondary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedTab == tab ? TatapTheme.primaryCyan : TatapTheme.border, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    
                    // Main Grid Content
                    if isLoading && animeList.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(TatapTheme.primaryCyan)
                                .scaleEffect(1.3)
                            Text("Mengambil katalog anime...")
                                .font(.system(size: 13))
                                .foregroundColor(TatapTheme.textMuted)
                        }
                        Spacer()
                    } else if let err = errorMessage, animeList.isEmpty {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 32))
                                .foregroundColor(.red)
                            Text("Gagal memuat data")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text(err)
                                .font(.system(size: 12))
                                .foregroundColor(TatapTheme.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Button("Coba Lagi") {
                                loadCurrentTab()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(TatapTheme.surfaceElevated)
                            .foregroundColor(TatapTheme.primaryCyan)
                            .cornerRadius(8)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(animeList) { anime in
                                    NavigationLink(destination: DetailView(anime: anime)) {
                                        AnimeCard(anime: anime)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                            .padding(.bottom, 30)
                        }
                        .refreshable {
                            loadCurrentTab()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if animeList.isEmpty {
                loadCurrentTab()
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadCurrentTab() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let items: [Anime]
                switch selectedTab {
                case .musim:
                    items = try await AniListClient.shared.getSeasonal(page: 1)
                case .airing:
                    items = try await AniListClient.shared.getAiring(page: 1)
                case .jadwal, .katalog:
                    items = try await AniListClient.shared.getCatalog(sort: "POPULARITY_DESC", page: 1)
                case .riwayat:
                    let rawHistory = LocalDatabase.shared.getHistory()
                    items = rawHistory.compactMap { h in
                        guard let id = Int(h["slug"] as? String ?? "") else { return nil }
                        return Anime(
                            id: id,
                            titleRomaji: h["title"] as? String ?? "",
                            titleEnglish: nil,
                            coverURL: h["poster"] as? String,
                            bannerURL: nil,
                            format: h["type"] as? String,
                            episodes: h["episode"] as? Int,
                            duration: nil,
                            averageScore: nil,
                            season: nil,
                            seasonYear: nil,
                            status: nil,
                            genres: [],
                            studio: nil,
                            synopsis: nil,
                            nextEpisode: nil,
                            nextAiringTime: nil
                        )
                    }
                case .favorit:
                    let rawBookmarks = LocalDatabase.shared.getBookmarks()
                    items = rawBookmarks.compactMap { b in
                        guard let id = Int(b["slug"] as? String ?? "") else { return nil }
                        return Anime(
                            id: id,
                            titleRomaji: b["title"] as? String ?? "",
                            titleEnglish: nil,
                            coverURL: b["poster"] as? String,
                            bannerURL: nil,
                            format: b["type"] as? String,
                            episodes: nil,
                            duration: nil,
                            averageScore: nil,
                            season: nil,
                            seasonYear: nil,
                            status: nil,
                            genres: [],
                            studio: nil,
                            synopsis: nil,
                            nextEpisode: nil,
                            nextAiringTime: nil
                        )
                    }
                }
                
                await MainActor.run {
                    self.animeList = items
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let items = try await AniListClient.shared.search(keyword: searchQuery, page: 1)
                await MainActor.run {
                    self.animeList = items
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
