import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var onCommit: () -> Void
    var onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(TatapTheme.primaryCyan)
                .font(.system(size: 14))
            
            Text("tatap$")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(TatapTheme.primaryCyan)
            
            TextField("cari judul anime, atau :p", text: $text, onCommit: onCommit)
                .font(.system(size: 13, design: .default))
                .foregroundColor(TatapTheme.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onClear()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(TatapTheme.textMuted)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(TatapTheme.surface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(TatapTheme.border, lineWidth: 1)
        )
    }
}
