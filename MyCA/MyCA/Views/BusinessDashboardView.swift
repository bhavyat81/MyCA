import SwiftUI

struct BusinessDashboardView: View {
    let business: Business
    @Environment(Store.self) private var store
    @State private var month: Int
    @State private var year: Int

    init(business: Business) {
        self.business = business
        let now = Date()
        _month = State(initialValue: Calendar.current.component(.month, from: now))
        _year  = State(initialValue: Calendar.current.component(.year, from: now))
    }

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingM) {
                    HStack {
                        Text(business.emoji).font(.system(size: 36))
                        VStack(alignment: .leading) {
                            Text(business.name)
                                .font(Theme.titleFont(size: 28))
                                .foregroundStyle(.white)
                            Text(business.address)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }

                    AppCard {
                        MonthSelector(month: $month, year: $year)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Revenue",
                                 value: Theme.currency(store.totalRevenue(businessId: business.id, year: year, month: month)),
                                 symbol: "dollarsign.circle.fill", tint: .green)
                        StatCard(title: "Salaries",
                                 value: Theme.currency(store.totalSalaries(businessId: business.id, year: year, month: month)),
                                 symbol: "person.2.fill", tint: .purple)
                        StatCard(title: "Expenses",
                                 value: Theme.currency(store.totalExpenses(businessId: business.id, year: year, month: month)),
                                 symbol: "cart.fill", tint: .orange)
                        let net = store.netProfit(businessId: business.id, year: year, month: month)
                        StatCard(title: "Net Profit",
                                 value: Theme.currency(net),
                                 symbol: net >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                 tint: net >= 0 ? .green : .red,
                                 isNegative: net < 0)
                    }
                }
                .padding(Theme.spacingL)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

