import SwiftUI
import Charts

struct ReportsView: View {
    @Environment(Store.self) private var store
    @State private var selectedBusinessId: String? = nil
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    BusinessPicker(businesses: Business.all, selected: $selectedBusinessId)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    Picker("Report", selection: $selectedTab) {
                        Text("Monthly").tag(0)
                        Text("HST").tag(1)
                        Text("Year").tag(2)
                        Text("Mileage").tag(3)
                        Text("Tax").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .padding(16)

                    ScrollView {
                        switch selectedTab {
                        case 0: MonthlyReportView(selectedBusinessId: selectedBusinessId, year: selectedYear)
                        case 1: HSTReportView(selectedBusinessId: selectedBusinessId, year: selectedYear)
                        case 2: YearReportView(selectedBusinessId: selectedBusinessId, year: selectedYear)
                        case 3: MileageView()
                        case 4: TaxEstimatorView()
                        default: EmptyView()
                        }
                    }
                }
            }
            .navigationTitle("Reports")
        }
    }
}

// MARK: - Monthly Report
struct MonthlyReportView: View {
    @Environment(Store.self) private var store
    let selectedBusinessId: String?
    let year: Int
    @State private var month: Int = Calendar.current.component(.month, from: Date())

    private var bizIds: [String] {
        selectedBusinessId.map { [$0] } ?? Business.all.map(\.id)
    }
    private var rev: Double  { bizIds.reduce(0) { $0 + store.totalRevenue(businessId: $1, year: year, month: month) } }
    private var sal: Double  { bizIds.reduce(0) { $0 + store.totalSalaries(businessId: $1, year: year, month: month) } }
    private var exp: Double  { bizIds.reduce(0) { $0 + store.totalExpenses(businessId: $1, year: year, month: month) } }
    private var net: Double  { rev - sal - exp }
    private var hst: Double  { bizIds.reduce(0) { $0 + store.hstOwed(businessId: $1, year: year, month: month) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppCard { MonthSelector(month: $month, year: .constant(year)) }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Revenue",  value: fmt(rev), symbol: "dollarsign.circle.fill", tint: .green)
                StatCard(title: "Salaries", value: fmt(sal), symbol: "person.2.fill", tint: .purple)
                StatCard(title: "Expenses", value: fmt(exp), symbol: "cart.fill", tint: .orange)
                StatCard(title: "HST Owed", value: fmt(hst), symbol: "percent", tint: .blue, isNegative: hst < 0)
            }

            GlassCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Profit / Loss")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(fmt(net))
                            .font(.title.weight(.bold))
                            .foregroundStyle(net >= 0 ? .green : .red)
                    }
                    Spacer()
                    Image(systemName: net >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(net >= 0 ? Color.green : Color.red)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func fmt(_ v: Double) -> String { Theme.currency(v) }
}

// MARK: - HST Report
struct HSTReportView: View {
    @Environment(Store.self) private var store
    let selectedBusinessId: String?
    let year: Int

    private var bizIds: [String] {
        selectedBusinessId.map { [$0] } ?? Business.all.map(\.id)
    }

    private struct Quarter { let name: String; let months: [Int] }
    private let quarters = [
        Quarter(name: "Q1 (Jan–Mar)",  months: [1,2,3]),
        Quarter(name: "Q2 (Apr–Jun)",  months: [4,5,6]),
        Quarter(name: "Q3 (Jul–Sep)",  months: [7,8,9]),
        Quarter(name: "Q4 (Oct–Dec)",  months: [10,11,12])
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(quarters, id: \.name) { q in
                let collected = bizIds.reduce(0.0) { acc, bId in
                    acc + q.months.reduce(0.0) { a, m in
                        a + store.revenues(businessId: bId, year: year, month: m)
                            .reduce(0) { $0 + $1.hstCollected }
                    }
                }
                let paid = bizIds.reduce(0.0) { acc, bId in
                    acc + q.months.reduce(0.0) { a, m in
                        a + store.expenses(businessId: bId, year: year, month: m)
                            .filter { $0.hstIncluded }
                            .reduce(0) { $0 + $1.hstAmount }
                    }
                }
                let owed = collected - paid
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(q.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        HStack {
                            Label("Collected", systemImage: "plus.circle").foregroundStyle(.green)
                            Spacer()
                            Text(Theme.currency(collected)).foregroundStyle(.primary)
                        }
                        .font(.subheadline)
                        HStack {
                            Label("Paid (ITCs)",  systemImage: "minus.circle").foregroundStyle(.orange)
                            Spacer()
                            Text(Theme.currency(paid)).foregroundStyle(.primary)
                        }
                        .font(.subheadline)
                        Divider()
                        HStack {
                            Text("HST Owed")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(Theme.currency(owed))
                                .font(.headline)
                                .foregroundStyle(owed >= 0 ? .red : .green)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Year Report
struct YearReportView: View {
    @Environment(Store.self) private var store
    let selectedBusinessId: String?
    let year: Int

    private var bizIds: [String] {
        selectedBusinessId.map { [$0] } ?? Business.all.map(\.id)
    }

    private struct MPoint: Identifiable {
        let id: Int; let month: Int; let rev: Double; let exp: Double
    }

    private var points: [MPoint] {
        (1...12).map { m in
            let r = bizIds.reduce(0) { $0 + store.totalRevenue(businessId: $1, year: year, month: m) }
            let e = bizIds.reduce(0) {
                $0 + store.totalExpenses(businessId: $1, year: year, month: m)
                   + store.totalSalaries(businessId: $1, year: year, month: m)
            }
            return MPoint(id: m, month: m, rev: r, exp: e)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(year) Year Overview")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Chart {
                        ForEach(points) { pt in
                            BarMark(
                                x: .value("Month", Calendar.current.shortMonthSymbols[pt.month-1]),
                                y: .value("Revenue", pt.rev)
                            )
                            .foregroundStyle(Color.green.opacity(0.8))

                            BarMark(
                                x: .value("Month", Calendar.current.shortMonthSymbols[pt.month-1]),
                                y: .value("Costs", pt.exp)
                            )
                            .foregroundStyle(Color.red.opacity(0.7))
                        }
                    }
                    .frame(height: 200)
                    HStack(spacing: 16) {
                        HStack(spacing: 4) { Circle().fill(.green).frame(width: 8, height: 8); Text("Revenue").font(.caption).foregroundStyle(.secondary) }
                        HStack(spacing: 4) { Circle().fill(.red).frame(width: 8, height: 8);   Text("Costs").font(.caption).foregroundStyle(.secondary) }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ReportsView().environment(Store())
}
