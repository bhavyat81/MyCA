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

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        GradientBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingM) {
                    HStack(spacing: Theme.spacingS) {
                        Text(business.emoji)
                            .font(.system(size: 44))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(business.name)
                                .font(Theme.titleFont(size: 30))
                                .foregroundStyle(.white)
                            Text(business.address)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }

                    AppCard {
                        MonthSelector(month: $month, year: $year)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        hubTile(title: "Revenue", emoji: "💵") {
                            RevenueView(business: business, year: year, month: month)
                        }
                        hubTile(title: "Salary", emoji: "👥") {
                            SalaryView(business: business, year: year, month: month)
                        }
                        hubTile(title: "Expenses", emoji: "🧾") {
                            ExpenseView(business: business, year: year, month: month)
                        }
                        hubTile(title: "Mileage", emoji: "🚗") {
                            MileageView(business: business, year: year, month: month)
                        }
                        hubTile(title: "Invoices", emoji: "🧾") {
                            InvoiceListView(business: business, year: year, month: month)
                        }
                        hubTile(title: "Reports", emoji: "📊") {
                            ReportsView(business: business, year: year, month: month)
                        }
                        hubTile(title: "Settings", emoji: "⚙️") {
                            BusinessSettingsView(business: business)
                        }
                    }
                }
                .padding(Theme.spacingL)
            }
        }
        .navigationTitle("Business Hub")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func hubTile<Destination: View>(
        title: String,
        emoji: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text(emoji)
                        .font(.system(size: 32))
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}
