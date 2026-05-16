import SwiftUI

struct RevenueView: View {
    @Environment(Store.self) private var store
    @State private var selectedBusinessId: String? = nil
    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var year: Int  = Calendar.current.component(.year,  from: Date())
    @State private var editingEntry: RevenueEntry?
    @State private var showingAdd = false
    @State private var searchText = ""

    private var activeBizId: String { selectedBusinessId ?? Business.all.first!.id }

    private var entries: [RevenueEntry] {
        let all = store.revenues(businessId: activeBizId, year: year, month: month)
            .sorted { $0.createdAt > $1.createdAt }
        if searchText.isEmpty { return all }
        return all.filter { $0.source.localizedCaseInsensitiveContains(searchText) }
    }

    private var total: Double { entries.reduce(0) { $0 + $1.amount } }
    private var hstTotal: Double { entries.reduce(0) { $0 + $1.hstCollected } }

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
                            Image(systemName: "dollarsign.circle.fill").foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Total Revenue")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("HST Collected: \(Theme.currency(hstTotal))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
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
                        EmptyState(symbol: "dollarsign.circle",
                                   title: "No Revenue Yet",
                                   caption: "Tap + to add your first revenue entry")
                        Spacer()
                    } else {
                        List {
                            ForEach(entries) { entry in
                                RevenueRowView(entry: entry)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Haptics.impact(.medium)
                                            store.delete(revenue: entry, businessId: activeBizId, year: year, month: month)
                                        } label: { Label("Delete", systemImage: "trash") }

                                        Button {
                                            editingEntry = entry
                                            showingAdd = true
                                        } label: { Label("Edit", systemImage: "pencil") }
                                            .tint(.gray)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            var copy = entry
                                            copy.id = UUID()
                                            copy.createdAt = Date()
                                            store.upsert(revenue: copy, businessId: activeBizId, year: year, month: month)
                                            Haptics.impact(.light)
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
            .navigationTitle("Revenue")
            .searchable(text: $searchText, prompt: "Search revenue…")
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
                AddRevenueView(existing: editingEntry, businessId: activeBizId) { entry in
                    store.upsert(revenue: entry, businessId: activeBizId, year: year, month: month)
                    Haptics.success()
                }
                .environment(store)
            }
        }
    }
}

private struct RevenueRowView: View {
    let entry: RevenueEntry

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: entry.paid ? "checkmark.circle.fill" : "clock.fill")
                    .font(.title3)
                    .foregroundStyle(entry.paid ? .green : .orange)
                    .frame(width: 36, height: 36)
                    .background((entry.paid ? Color.green : Color.orange).opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.source)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let inv = entry.invoiceNumber {
                        Text("Invoice: \(inv)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if entry.hstCollected > 0 {
                        Text("HST: \(Theme.currency(entry.hstCollected))")
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
