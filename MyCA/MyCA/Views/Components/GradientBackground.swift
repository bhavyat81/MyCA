import SwiftUI

struct GradientBackground<Content: View>: View {
    @Environment(Store.self) private var store
    @ViewBuilder var content: Content

    var body: some View {
        LinearGradient(
            colors: store.selectedTheme.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(content)
    }
}

struct ThemedBackground: ViewModifier {
    @Environment(Store.self) private var store

    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: store.selectedTheme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackground())
    }
}

