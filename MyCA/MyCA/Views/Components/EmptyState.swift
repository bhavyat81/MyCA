import SwiftUI

struct EmptyState: View {
    let symbol: String
    let title: String
    let caption: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.5))
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
