import SwiftUI

struct ExpenseView: View {
    let business: Business
    let year: Int
    let month: Int

    @State private var entries: [ExpenseEntry] = []
    @State private var editingEntry: ExpenseEntry?
    @State private var showingAdd = false

    private var monthName: String {
        Calendar.current.monthSymbols[month - 1]
    }

    private var total: Double {
        entries.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        GradientBackground {
            VStack(alignment: .leading, spacing: Theme.spacingM) {
                Text(business.name)
                    .font(Theme.titleFont(size: 28))
                    .foregroundStyle(.white)
                Text("\(monthName) \(year)")
                    .foregroundStyle(.white.opacity(0.85))

                Button {
                    editingEntry = nil
                    showingAdd = true
                } label: {
                    Label("+ Add Expense", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)

                List {
                    ForEach(entries) { entry in
                        AppCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.description)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("Category: \(categoryLabel(for: entry))")
                                    .foregroundStyle(.white.opacity(0.85))
                                Text(currency(entry.amount))
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            editingEntry = entry
                            showingAdd = true
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                AppCard {
                    Text("Total Expenses for \(monthName) \(year): \(currency(total))")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .padding(Theme.spacingL)
        }
        .navigationTitle("Expenses")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
        .sheet(isPresented: $showingAdd) {
            AddExpenseView(existing: editingEntry) { entry in
                if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                    entries[index] = entry
                } else {
                    entries.append(entry)
                }
                persist()
            }
            .presentationDetents([.medium])
        }
    }

    private func load() {
        entries = Storage.expenses(businessId: business.id, year: year, month: month)
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        Storage.saveExpenses(entries, businessId: business.id, year: year, month: month)
    }

    private func categoryLabel(for entry: ExpenseEntry) -> String {
        if let category = entry.category?.trimmingCharacters(in: .whitespacesAndNewlines), !category.isEmpty {
            return category
        }
        return "-"
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
