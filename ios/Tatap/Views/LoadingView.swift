import SwiftUI

struct LoadingView: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 4)
                        .frame(width: 90, height: 90)
                        .scaleEffect(isPulsing ? 1.2 : 0.95)
                        .opacity(isPulsing ? 0.2 : 0.8)
                    
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.cyan, .purple, .pink, .cyan]),
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(Angle(degrees: isPulsing ? 360 : 0))
                    
                    Image(systemName: "play.tv.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.cyan)
                }
                
                VStack(spacing: 6) {
                    Text("TATAP")
                        .font(.system(size: 24, weight: .heavy, design: .monospaced))
                        .tracking(4)
                        .foregroundColor(.white)
                    
                    Text("Memulai runtime lokal...")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
