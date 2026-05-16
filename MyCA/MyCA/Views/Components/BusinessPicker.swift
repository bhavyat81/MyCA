import SwiftUI

struct BusinessPicker: View {
    let businesses: [Business]
    @Binding var selected: String?   // nil = "All"

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                PillButton(label: "All", emoji: "🏢", isSelected: selected == nil) {
                    selected = nil
                }
                ForEach(businesses) { biz in
                    PillButton(label: biz.name, emoji: biz.emoji, isSelected: selected == biz.id) {
                        selected = biz.id
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

private struct PillButton: View {
    let label: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(emoji)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline.weight(isSelected ? .bold : .regular))
            }
            .foregroundStyle(isSelected ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.white : Color.white.opacity(0.15))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
