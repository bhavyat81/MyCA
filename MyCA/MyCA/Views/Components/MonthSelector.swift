import SwiftUI

struct MonthSelector: View {
    @Binding var month: Int
    @Binding var year: Int
    @Environment(Store.self) private var store

    private let monthSymbols = Calendar.current.shortMonthSymbols

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingXS) {
                    ForEach(1...12, id: \.self) { value in
                        Button(monthSymbols[value - 1]) {
                            month = value
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, Theme.spacingS)
                        .padding(.vertical, Theme.spacingXS)
                        .background(month == value ? store.selectedTheme.accent.opacity(0.35) : Color.white.opacity(0.1))
                        .foregroundStyle(month == value ? Color.primary : Color.secondary)
                        .fontWeight(month == value ? .bold : .regular)
                        .clipShape(Capsule())
                    }
                }
            }

            HStack {
                Button {
                    year -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primary)
                }

                Text("\(year)")
                    .foregroundStyle(.primary)
                    .font(.headline)
                    .frame(minWidth: 80)

                Button {
                    year += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

