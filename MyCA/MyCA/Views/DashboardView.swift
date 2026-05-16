import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(Store.self) private var store
    @State private var selectedBusinessId: String? = nil
    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var year: Int  = Calendar.current.component(.year,  from: Date())

    private var businesses: [Business] { Business.all }

    private var activeBizIds: [String] {
        selectedBusinessId.map { [$0] } ?? businesses.map(\.id)
    }

    private var revenue: Double {
        activeBizIds.reduce(0) { $0 + store.totalRevenue(businessId: $1, year: year, month: month) }
    }
    private var salaries: Double {
        activeBizIds.reduce(0) { $0 + store.totalSalaries(businessId: $1, year: year, month: month) }
    }
    private var expenses: Double {
        activeBizIds.reduce(0) { $0 + store.totalExpenses(businessId: $1, year: year, month: month) }
    }
    private var net: Double { revenue - salaries - expenses }
    private var hstOwed: Double {
        activeBizIds.reduce(0) { $0 + store.hstOwed(businessId: $1, year: year, month: month) }
    }

    // 6-month trend data
    private var trendData: [MonthPoint] {
        (0..<6).map { offset -> MonthPoint in
            var m = month - offset
            var y = year
            while m < 1 { m += 12; y -= 1 }
            let rev = activeBizIds.reduce(0) { $0 + store.totalRevenue(businessId: $1, year: y, month: m) }
            let exp = activeBizIds.reduce(0) { $0 + store.totalExpenses(businessId: $1, year: y, month: m) }
            let sal = activeBizIds.reduce(0) { $0 + store.totalSalaries(businessId: $1, year: y, month: m) }
            return MonthPoint(month: m, year: y, revenue: rev, expenses: exp + sal)
        }.reversed()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Business picker
                        BusinessPicker(businesses: businesses, selected: $selectedBusinessId)

                        // Month selector
                        AppCard {
                            MonthSelector(month: $month, year: $year)
                        }

                        // Stat grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Revenue", value: fmt(revenue),
                                     symbol: "dollarsign.circle.fill", tint: .green)
                            StatCard(title: "Salaries", value: fmt(salaries),
                                     symbol: "person.2.fill", tint: .purple)
                            StatCard(title: "Expenses", value: fmt(expenses),
                                     symbol: "cart.fill", tint: .orange)
                            StatCard(title: "HST Owed", value: fmt(hstOwed),
                                     symbol: "percent", tint: .blue,
                                     isNegative: hstOwed < 0)
                        }

                        // Net profit card
                        GlassCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Net Profit / Loss")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Text(fmt(net))
                                        .font(.largeTitle.weight(.bold))
                                        .foregroundStyle(net >= 0 ? Color.green : Color.red)
                                        .contentTransition(.numericText())
                                        .animation(.easeInOut(duration: 0.4), value: net)
                                }
                                Spacer()
                                Image(systemName: net >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(net >= 0 ? Color.green : Color.red)
                            }
                        }

                        // 6-month chart
                        if !trendData.isEmpty {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("6-Month Overview")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Chart {
                                        ForEach(trendData) { pt in
                                            BarMark(
                                                x: .value("Month", pt.label),
                                                y: .value("Revenue", pt.revenue)
                                            )
                                            .foregroundStyle(Color.green.opacity(0.8))
                                            .cornerRadius(4)

                                            BarMark(
                                                x: .value("Month", pt.label),
                                                y: .value("Costs", pt.expenses)
                                            )
                                            .foregroundStyle(Color.red.opacity(0.7))
                                            .cornerRadius(4)
                                        }
                                    }
                                    .frame(height: 160)
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { _ in
                                            AxisValueLabel().foregroundStyle(Color.secondary)
                                        }
                                    }
                                    HStack(spacing: 16) {
                                        legendDot(color: .green,  label: "Revenue")
                                        legendDot(color: .red,    label: "Costs")
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Dashboard")
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func fmt(_ v: Double) -> String { Theme.currency(v) }
}

private struct MonthPoint: Identifiable {
    let month: Int; let year: Int
    let revenue: Double; let expenses: Double
    var id: String { "\(year)-\(month)" }
    var label: String { Calendar.current.shortMonthSymbols[month - 1] }
}

#Preview {
    DashboardView().environment(Store())
}
