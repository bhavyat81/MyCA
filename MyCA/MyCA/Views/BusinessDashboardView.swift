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

// MARK: - Per-business settings
// Inlined here so it compiles without needing a pbxproj entry.
struct BusinessSettingsView: View {
    let business: Business
    @Environment(Store.self) private var store
    @State private var hstRateText = ""
    @State private var sqftUsedText = ""
    @State private var sqftTotalText = ""

    private var homeOffice: HomeOffice? {
        store.homeOffices.first { $0.businessId == business.id }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Form {
                Section("Tax") {
                    HStack {
                        Text("HST Rate %")
                        Spacer()
                        TextField("13", text: $hstRateText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    .foregroundStyle(.primary)
                    .onChange(of: hstRateText) { _, value in
                        if let rate = Double(value), rate > 0 {
                            store.setHstRate(rate / 100, for: business.id)
                        }
                    }
                }

                Section("Home Office") {
                    TextField("Sq ft used", text: $sqftUsedText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.primary)
                    TextField("Sq ft total", text: $sqftTotalText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.primary)
                    if let used = Double(sqftUsedText), let total = Double(sqftTotalText), total > 0 {
                        Text("Home office %: \(Int((used / total) * 100))%")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }

                Section("Business Data") {
                    NavigationLink("Employees") { EmployeeRosterView().environment(store) }
                    NavigationLink("Categories") { CategoriesSettingsView().environment(store) }
                    NavigationLink("Vendors") { VendorsView().environment(store) }
                    NavigationLink("Clients") { ClientsView().environment(store) }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .onAppear {
            hstRateText = String(Int(store.hstRate(for: business.id) * 100))
            sqftUsedText = homeOffice.map { String($0.sqftUsed) } ?? ""
            sqftTotalText = homeOffice.map { String($0.sqftTotal) } ?? ""
        }
        .onDisappear {
            guard let used = Double(sqftUsedText), let total = Double(sqftTotalText), used >= 0, total > 0 else {
                return
            }
            let updated = HomeOffice(businessId: business.id, sqftUsed: used, sqftTotal: total)
            if let idx = store.homeOffices.firstIndex(where: { $0.businessId == business.id }) {
                store.homeOffices[idx] = updated
            } else {
                store.homeOffices.append(updated)
            }
            store.saveHomeOffices()
        }
    }
}
