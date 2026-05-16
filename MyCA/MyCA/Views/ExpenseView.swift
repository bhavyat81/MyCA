import SwiftUI

struct ExpenseView: View {
    @Environment(Store.self) private var store
    @State private var selectedBusinessId: String? = nil
    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var year: Int  = Calendar.current.component(.year,  from: Date())
    @State private var editingEntry: ExpenseEntry?
    @State private var showingAdd = false
    @State private var searchText = ""

    private var activeBizId: String { selectedBusinessId ?? Business.all.first?.id ?? "planet-rehab" }

    private var entries: [ExpenseEntry] {
        let all = store.expenses(businessId: activeBizId, year: year, month: month)
            .sorted { $0.createdAt > $1.createdAt }
        if searchText.isEmpty { return all }
        return all.filter {
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    private var total: Double { entries.reduce(0) { $0 + $1.amount } }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        BusinessPicker(businesses: Business.all, selected: $selectedBusinessId)
                        AppCard { MonthSelector(month: $month, year: $year) }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    GlassCard {
                        HStack {
                            Image(systemName: "cart.fill").foregroundStyle(.orange)
                            Text("Total Expenses")
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

                    if entries.isEmpty {
                        Spacer()
                        EmptyState(symbol: "cart.badge.plus",
                                   title: "No Expenses Yet",
                                   caption: "Tap + to add your first expense")
                        Spacer()
                    } else {
                        List {
                            ForEach(entries) { entry in
                                ExpenseRowView(entry: entry, store: store)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Haptics.impact(.medium)
                                            store.delete(expense: entry, businessId: activeBizId, year: year, month: month)
                                        } label: { Label("Delete", systemImage: "trash") }

                                        Button {
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
                                            store.upsert(expense: copy, businessId: activeBizId, year: year, month: month)
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
                    }
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, prompt: "Search expenses…")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editingEntry = nil
                        showingAdd = true
                        Haptics.impact(.medium)
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddExpenseView(existing: editingEntry, businessId: activeBizId) { entry in
                    store.upsert(expense: entry, businessId: activeBizId, year: year, month: month)
                    Haptics.success()
                }
                .environment(store)
            }
        }
    }
}

private struct ExpenseRowView: View {
    let entry: ExpenseEntry
    let store: Store

    private var category: Category? {
        entry.categoryId.flatMap { id in store.categories.first { $0.id == id } }
    }

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: category?.symbolName ?? "cart.fill")
                    .font(.title3)
                    .foregroundStyle(category.map { Color(hex: $0.colorHex) } ?? .orange)
                    .frame(width: 36, height: 36)
                    .background((category.map { Color(hex: $0.colorHex) } ?? .orange).opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.description)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let cat = category {
                        Text(cat.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let cat = entry.category, !cat.isEmpty {
                        Text(cat)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if entry.hstIncluded {
                        Text("Base: \(Theme.currency(entry.preTaxAmount))  HST: \(Theme.currency(entry.hstAmount))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(Theme.currency(entry.amount))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
            }
        }
    }
}

