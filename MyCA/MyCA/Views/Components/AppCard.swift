import SwiftUI

struct AppCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Theme.spacingM)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    AppCard {
        Text("Glass Card")
            .foregroundStyle(.primary)
    }
    .padding()
    .background(Color.indigo)
}

