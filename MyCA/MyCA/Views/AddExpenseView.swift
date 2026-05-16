import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss

    let existing: ExpenseEntry?
    let onSave: (ExpenseEntry) -> Void

    @State private var descriptionText: String
    @State private var amountText: String
    @State private var category: String

    init(existing: ExpenseEntry?, onSave: @escaping (ExpenseEntry) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _descriptionText = State(initialValue: existing?.description ?? "")
        _amountText = State(initialValue: existing.map { String($0.amount) } ?? "")
        _category = State(initialValue: existing?.category ?? "")
    }

    private var amount: Double { Double(amountText) ?? 0 }

    var body: some View {
        NavigationStack {
            GradientBackground {
                Form {
                    TextField("Description", text: $descriptionText)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    TextField("Category (optional)", text: $category)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existing == nil ? "Add Expense" : "Edit Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? ExpenseEntry(description: "", amount: 0)
                        entry.description = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.amount = amount
                        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.category = trimmed.isEmpty ? nil : trimmed
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || amount <= 0)
                }
            }
        }
    }
}
