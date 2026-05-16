import SwiftUI

struct SalaryView: View {
    @Environment(Store.self) private var store
    let business: Business?
    let year: Int?
    let month: Int?

    @State private var selectedBusinessId: String?
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    @State private var editingEntry: SalaryEntry?
    @State private var showingAdd = false
    @State private var searchText = ""

    init(business: Business? = nil, year: Int? = nil, month: Int? = nil) {
        self.business = business
        self.year = year
        self.month = month
        _selectedBusinessId = State(initialValue: business?.id)
        _selectedMonth = State(initialValue: month ?? Calendar.current.component(.month, from: Date()))
        _selectedYear = State(initialValue: year ?? Calendar.current.component(.year, from: Date()))
    }

    private var activeBizId: String {
        business?.id ?? selectedBusinessId ?? Business.all.first?.id ?? "planet-rehab"
    }

    private var activeBizName: String {
        business?.name ?? Business.all.first(where: { $0.id == activeBizId })?.name ?? "Business"
    }

    private var entries: [SalaryEntry] {
        let all = store.salaries(businessId: activeBizId, year: selectedYear, month: selectedMonth)
            .sorted { $0.createdAt > $1.createdAt }
        if searchText.isEmpty { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var totalGross: Double { entries.reduce(0) { $0 + $1.gross } }
    private var payrollEntries: [SalaryEntry] { entries.filter { $0.paymentType == .payroll } }
    private var totalNetPaid: Double {
        payrollEntries.reduce(0) {
            $0 + Payroll.calculate(hours: $1.hours, rate: $1.payRate, bonus: $1.bonus).net
        }
    }
    private var selectedMonthName: String {
        Calendar.current.monthSymbols[max(1, min(12, selectedMonth)) - 1]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AppCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activeBizName)
                                .font(.headline)
                            Text("\(selectedMonthName) \(selectedYear)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if entries.isEmpty {
                    Spacer()
                    EmptyState(symbol: "person.badge.plus", title: "No salaries yet.", caption: "Tap + to add.")
                    Spacer()
                } else {
                    List {
                        ForEach(entries) { entry in
                            SalaryRowView(entry: entry)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Haptics.impact(.medium)
                                        store.delete(salary: entry, businessId: activeBizId, year: selectedYear, month: selectedMonth)
                                    } label: { Label("Delete", systemImage: "trash") }

                                    Button {
                                        Haptics.impact(.light)
                                        editingEntry = entry
                                        showingAdd = true
                                    } label: { Label("Edit", systemImage: "pencil") }
                                        .tint(.gray)
                                }
                                .onTapGesture {
                                    editingEntry = entry
                                    showingAdd = true
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Total Gross")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(Theme.currency(totalGross))
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        if !payrollEntries.isEmpty {
                            HStack {
                                Text("Total Net Paid")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(Theme.currency(totalNetPaid))
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Salary")
        .searchable(text: $searchText, prompt: "Search employees…")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editingEntry = nil
                    showingAdd = true
                    Haptics.impact(.medium)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddSalaryView(existing: editingEntry, businessId: activeBizId) { entry in
                store.upsert(salary: entry, businessId: activeBizId, year: selectedYear, month: selectedMonth)
                Haptics.success()
            }
            .environment(store)
        }
    }
}

private struct SalaryRowView: View {
    let entry: SalaryEntry
    private var payroll: PayrollResult { Payroll.calculate(hours: entry.hours, rate: entry.payRate, bonus: entry.bonus) }

    private var badgeColor: Color {
        entry.paymentType == .contract ? .gray : .purple
    }

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(Color.purple)
                    .frame(width: 36, height: 36)
                    .background(Color.purple.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(entry.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(entry.paymentType == .contract ? "Contract" : "Payroll")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(badgeColor.opacity(0.2))
                            .clipShape(Capsule())
                            .foregroundStyle(badgeColor)
                    }
                    Text("\(entry.hours, specifier: "%.1f")h × \(Theme.currency(entry.payRate))/h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(Theme.currency(entry.gross))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    if entry.paymentType == .payroll {
                        Text("Net: \(Theme.currency(payroll.net))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
