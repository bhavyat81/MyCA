import SwiftUI

struct AddSalaryView: View {
    @Environment(\.dismiss) private var dismiss

    let existing: SalaryEntry?
    let onSave: (SalaryEntry) -> Void

    @State private var name: String
    @State private var hoursText: String
    @State private var rateText: String

    init(existing: SalaryEntry?, onSave: @escaping (SalaryEntry) -> Void) {
        self.existing = existing
        self.onSave = onSave
        _name = State(initialValue: existing?.name ?? "")
        _hoursText = State(initialValue: existing.map { String($0.hours) } ?? "")
        _rateText = State(initialValue: existing.map { String($0.payRate) } ?? "")
    }

    private var hours: Double { Double(hoursText) ?? 0 }
    private var payRate: Double { Double(rateText) ?? 0 }

    var body: some View {
        NavigationStack {
            GradientBackground {
                Form {
                    Section("Employee") {
                        TextField("Name", text: $name)
                        TextField("Hours", text: $hoursText)
                            .keyboardType(.decimalPad)
                        TextField("Pay rate", text: $rateText)
                            .keyboardType(.decimalPad)
                    }

                    Section("Total") {
                        Text(currency(hours * payRate))
                            .font(.headline)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existing == nil ? "Add Salary" : "Edit Salary")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? SalaryEntry(name: "", hours: 0, payRate: 0)
                        entry.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.hours = hours
                        entry.payRate = payRate
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hours <= 0 || payRate <= 0)
                }
            }
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
