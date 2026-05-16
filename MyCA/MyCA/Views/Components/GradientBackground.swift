import SwiftUI

struct GradientBackground<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        LinearGradient(
            colors: [Theme.backgroundStart, Theme.backgroundMiddle, Theme.backgroundEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(content)
    }
}
