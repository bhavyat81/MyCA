import SwiftUI

struct MonthSelector: View {
    @Binding var month: Int
    @Binding var year: Int

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
                        .background(month == value ? Theme.accent.opacity(0.25) : Theme.cardBackground)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                }
            }

            HStack {
                Button {
                    year -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                }

                Text("\(year)")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .frame(minWidth: 80)

                Button {
                    year += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
