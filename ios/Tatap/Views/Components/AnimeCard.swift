import SwiftUI

struct AnimeCard: View {
    let anime: Anime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                // Cover Image
                AsyncImage(url: URL(string: anime.coverURL ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(TatapTheme.surfaceElevated)
                            .overlay(ProgressView().tint(TatapTheme.primaryCyan))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Rectangle()
                            .fill(TatapTheme.surfaceElevated)
                            .overlay(Image(systemName: "film").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 190)
                .clipped()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(TatapTheme.border, lineWidth: 1)
                )
                
                // Score Badge
                if let score = anime.averageScore, score > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", Double(score) / 10.0))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(6)
                    .padding(6)
                }
                
                // Format & Episode Badge (Bottom Left)
                VStack {
                    Spacer()
                    HStack {
                        Text(anime.formattedEpisodes)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(TatapTheme.surface.opacity(0.85))
                            .cornerRadius(4)
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .frame(height: 190)
            
            // Title
            Text(anime.displayTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(TatapTheme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Format / Year subtitle
            HStack(spacing: 4) {
                if let fmt = anime.format {
                    Text(fmt)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(TatapTheme.primaryCyan)
                }
                if let year = anime.seasonYear {
                    Text("• \(year)")
                        .font(.system(size: 10))
                        .foregroundColor(TatapTheme.textMuted)
                }
            }
        }
    }
}
