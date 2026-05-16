import SwiftUI

struct SalaryView: View {
    @Environment(Store.self) private var store
    @State private var selectedBusinessId: String? = nil
    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var year: Int  = Calendar.current.component(.year,  from: Date())
    @State private var editingEntry: SalaryEntry?
    @State private var showingAdd = false
    @State private var searchText = ""

    private var activeBizId: String { selectedBusinessId ?? Business.all.first!.id }
    private var activeBiz: Business { Business.all.first { $0.id == activeBizId } ?? Business.all[0] }

    private var entries: [SalaryEntry] {
        let all = store.salaries(businessId: activeBizId, year: year, month: month)
            .sorted { $0.createdAt > $1.createdAt }
        if searchText.isEmpty { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var total: Double { entries.reduce(0) { $0 + $1.gross } }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Business picker + month selector
                    VStack(spacing: 12) {
                        BusinessPicker(businesses: Business.all, selected: $selectedBusinessId)
                        AppCard { MonthSelector(month: $month, year: $year) }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Total card
                    GlassCard {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.purple)
                            Text("Total Salaries")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(Theme.currency(total))
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.4), value: total)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // List
                    if entries.isEmpty {
                        Spacer()
                        EmptyState(symbol: "person.badge.plus",
                                   title: "No Salaries Yet",
                                   caption: "Tap + to add your first salary entry")
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
                                            store.delete(salary: entry, businessId: activeBizId, year: year, month: month)
                                        } label: { Label("Delete", systemImage: "trash") }

                                        Button {
                                            Haptics.impact(.light)
                                            editingEntry = entry
                                            showingAdd = true
                                        } label: { Label("Edit", systemImage: "pencil") }
                                            .tint(.gray)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            Haptics.impact(.light)
                                            var copy = entry
                                            copy.id = UUID()
                                            copy.createdAt = Date()
                                            store.upsert(salary: copy, businessId: activeBizId, year: year, month: month)
                                        } label: { Label("Duplicate", systemImage: "doc.on.doc") }
                                            .tint(.blue)
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
                        .refreshable { /* re-read */ }
                    }
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
                AddSalaryView(
                    existing: editingEntry,
                    businessId: activeBizId
                ) { entry in
                    store.upsert(salary: entry, businessId: activeBizId, year: year, month: month)
                    Haptics.success()
                }
                .environment(store)
            }
        }
    }
}

private struct SalaryRowView: View {
    let entry: SalaryEntry
    private var payroll: PayrollResult { Payroll.calculate(hours: entry.hours, rate: entry.payRate, bonus: entry.bonus) }

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(.purple)
                    .frame(width: 36, height: 36)
                    .background(Color.purple.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(entry.hours, specifier: "%.1f")h × \(Theme.currency(entry.payRate))/h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(Theme.currency(payroll.gross))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("Net: \(Theme.currency(payroll.net))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

