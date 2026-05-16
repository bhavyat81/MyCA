import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color
    var subtitle: String? = nil
    var isNegative: Bool = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: symbol)
                        .foregroundStyle(tint)
                        .font(.subheadline.weight(.semibold))
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(isNegative ? Color.red : Color.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.4), value: value)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
