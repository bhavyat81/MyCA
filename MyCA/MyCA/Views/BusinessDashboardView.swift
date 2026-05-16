import SwiftUI

struct BusinessDashboardView: View {
    let business: Business
    @State private var month: Int
    @State private var year: Int

    init(business: Business) {
        self.business = business
        let now = Date()
        _month = State(initialValue: Calendar.current.component(.month, from: now))
        _year = State(initialValue: Calendar.current.component(.year, from: now))
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingM) {
                    Text(business.name)
                        .font(Theme.titleFont(size: 30))
                        .foregroundStyle(.white)
                    Text(business.address)
                        .foregroundStyle(.white.opacity(0.85))

                    AppCard {
                        MonthSelector(month: $month, year: $year)
                    }

                    HStack(spacing: Theme.spacingM) {
                        NavigationLink {
                            SalaryView(business: business, year: year, month: month)
                        } label: {
                            DashboardTile(icon: "💰", title: "Salary")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ExpenseView(business: business, year: year, month: month)
                        } label: {
                            DashboardTile(icon: "🧾", title: "Expenses")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.spacingL)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DashboardTile: View {
    let icon: String
    let title: String

    var body: some View {
        AppCard {
            VStack(spacing: Theme.spacingS) {
                Text(icon)
                    .font(.system(size: 34))
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 140)
        }
    }
}
