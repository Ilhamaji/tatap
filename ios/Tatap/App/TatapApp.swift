import SwiftUI

@main
struct TatapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isServerReady = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isServerReady {
                    MainWebView(url: TatapConfig.localServerURL)
                        .ignoresSafeArea()
                        .transition(.opacity)
                } else {
                    LoadingView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                startLocalServer()
            }
        }
    }
    
    private func startLocalServer() {
        TatapHTTPServer.shared.start()
        
        // Check server ping until ready
        Task {
            var ready = false
            for _ in 0..<20 {
                do {
                    let (_, response) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:\(TatapConfig.serverPort)/api/ping")!)
                    if (response as? HTTPURLResponse)?.statusCode == 200 {
                        ready = true
                        break
                    }
                } catch {
                    try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
                }
            }
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isServerReady = true
                }
            }
        }
    }
}
