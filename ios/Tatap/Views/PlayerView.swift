import SwiftUI
import AVKit
import MediaPlayer

struct PlayerView: View {
    let anime: Anime
    let episode: Episode
    @Environment(\.presentationMode) var presentationMode
    
    @State private var player: AVPlayer? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var showControls = true
    @State private var controlsTimer: Timer? = nil
    
    // Gesture Volume & Brightness Accumulators (Patent Policy AGENTS.md)
    @State private var currentBrightnessFraction: Float = Float(UIScreen.main.brightness)
    @State private var currentVolumeFraction: Float = 0.5
    @State private var gestureHUDText: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let p = player {
                NativeVideoView(player: p)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                            if showControls { resetControlsTimer() }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                handleDragGesture(value)
                            }
                            .onEnded { _ in
                                gestureHUDText = nil
                            }
                    )
            }
            
            // Loading Overlay
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(TatapTheme.primaryCyan)
                        .scaleEffect(1.5)
                    Text("Memuat stream...")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            // Error Overlay
            if let err = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    Button("Tutup") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(TatapTheme.surfaceElevated)
                    .foregroundColor(TatapTheme.primaryCyan)
                    .cornerRadius(8)
                }
            }
            
            // Gesture HUD Overlay (Brightness & Volume indicator)
            if let hud = gestureHUDText {
                Text(hud)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .transition(.opacity)
            }
            
            // Player Controls Overlay
            if showControls && !isLoading && errorMessage == nil {
                VStack {
                    // Top Bar
                    HStack {
                        Button(action: {
                            cleanupPlayer()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(anime.displayTitle)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(episode.title)
                                .font(.system(size: 12))
                                .foregroundColor(TatapTheme.primaryCyan)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Bottom Controls Bar
                    VStack(spacing: 8) {
                        // Slider Progress
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Slider(value: Binding(
                                get: { currentTime },
                                set: { newTime in
                                    currentTime = newTime
                                    player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
                                }
                            ), in: 0...max(duration, 1))
                            .tint(TatapTheme.primaryCyan)
                            
                            Text(formatTime(duration))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(TatapTheme.textMuted)
                        }
                        .padding(.horizontal, 20)
                        
                        // Play/Pause & Skip buttons
                        HStack(spacing: 36) {
                            Button(action: { seekBy(-10) }) {
                                Image(systemName: "gobackward.10")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { togglePlayPause() }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { seekBy(10) }) {
                                Image(systemName: "goforward.10")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .background(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            AppDelegate.orientationLock = .landscape
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            resolveAndStartStream()
        }
        .onDisappear {
            AppDelegate.orientationLock = .allButUpsideDown
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            cleanupPlayer()
        }
    }
    
    // MARK: - Stream Resolution
    private func resolveAndStartStream() {
        Task {
            do {
                let streamSource = try await HiAnimeScraper.shared.resolveStream(episodeId: episode.id)
                await MainActor.run {
                    self.setupPlayer(streamSource: streamSource)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Gagal memuat video: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func setupPlayer(streamSource: StreamSource) {
        let headers: [String: String] = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15",
            "Referer": streamSource.referer,
            "Origin": streamSource.referer
        ]
        
        let asset = AVURLAsset(url: streamSource.masterURL, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: asset)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.allowsExternalPlayback = true
        
        // Time observer
        avPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            self.currentTime = time.seconds
            if let d = avPlayer.currentItem?.duration.seconds, !d.isNaN {
                self.duration = d
            }
        }
        
        self.player = avPlayer
        self.isLoading = false
        avPlayer.play()
        self.isPlaying = true
        resetControlsTimer()
        
        // Save Watch History
        LocalDatabase.shared.addHistory(
            slug: "\(anime.id)",
            title: anime.displayTitle,
            episode: episode.number,
            mode: "sub",
            progress: 0,
            poster: anime.coverURL ?? "",
            type: anime.format ?? "TV"
        )
    }
    
    private func togglePlayPause() {
        guard let p = player else { return }
        if isPlaying {
            p.pause()
            isPlaying = false
        } else {
            p.play()
            isPlaying = true
            resetControlsTimer()
        }
    }
    
    private func seekBy(_ seconds: Double) {
        guard let p = player else { return }
        let target = max(0, min(currentTime + seconds, duration))
        p.seek(to: CMTime(seconds: target, preferredTimescale: 600))
        resetControlsTimer()
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            withAnimation {
                if self.isPlaying {
                    self.showControls = false
                }
            }
        }
    }
    
    private func cleanupPlayer() {
        controlsTimer?.invalidate()
        player?.pause()
        player = nil
    }
    
    private func handleDragGesture(_ value: DragGesture.Value) {
        let isRightSide = value.startLocation.x > (UIScreen.main.bounds.width / 2)
        let translationY = -Float(value.translation.height)
        
        if isRightSide {
            // Brightness control
            let delta = translationY / 300.0
            let newBrightness = max(0.01, min(1.0, currentBrightnessFraction + delta))
            UIScreen.main.brightness = CGFloat(newBrightness)
            gestureHUDText = String(format: "☀️ Kecerahan: %d%%", Int(newBrightness * 100))
        } else {
            // Volume indicator simulation
            let delta = translationY / 300.0
            let newVolume = max(0.0, min(1.0, currentVolumeFraction + delta))
            player?.volume = newVolume
            gestureHUDText = String(format: "🔊 Volume: %d%%", Int(newVolume * 100))
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && seconds >= 0 else { return "00:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Native Video Layer Representable
struct NativeVideoView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.allowsPictureInPicturePlayback = true
        controller.videoGravity = .resizeAspect
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
