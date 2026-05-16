import SwiftUI

struct AddSalaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let existing: SalaryEntry?
    let businessId: String
    let onSave: (SalaryEntry) -> Void

    @State private var name: String
    @State private var hoursText: String
    @State private var rateText: String
    @State private var bonusText: String
    @State private var notes: String

    init(existing: SalaryEntry?, businessId: String, onSave: @escaping (SalaryEntry) -> Void) {
        self.existing = existing
        self.businessId = businessId
        self.onSave = onSave
        _name      = State(initialValue: existing?.name ?? "")
        _hoursText = State(initialValue: existing.map { String($0.hours) } ?? "")
        _rateText  = State(initialValue: existing.map { String($0.payRate) } ?? "")
        _bonusText = State(initialValue: existing.map { String($0.bonus) } ?? "")
        _notes     = State(initialValue: existing?.notes ?? "")
    }

    private var hours:   Double { Double(hoursText) ?? 0 }
    private var payRate: Double { Double(rateText)  ?? 0 }
    private var bonus:   Double { Double(bonusText) ?? 0 }

    private var payroll: PayrollResult {
        Payroll.calculate(hours: hours, rate: payRate, bonus: bonus)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Employee Name", text: $name)
                            .foregroundStyle(.primary)
                        TextField("Hours", text: $hoursText)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                        TextField("Pay Rate ($/h)", text: $rateText)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                        TextField("Bonus", text: $bonusText)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                        TextField("Notes", text: $notes)
                            .foregroundStyle(.primary)
                    } header: {
                        Text("Employee Details")
                    }

                    if hours > 0 && payRate > 0 {
                        Section {
                            PayrollBreakdownRow(label: "Gross Pay",  value: payroll.gross,  color: .primary)
                            PayrollBreakdownRow(label: "CPP",        value: -payroll.cpp,   color: .orange)
                            PayrollBreakdownRow(label: "EI",         value: -payroll.ei,    color: .yellow)
                            PayrollBreakdownRow(label: "Federal Tax",value: -payroll.fedTax,color: .red)
                            PayrollBreakdownRow(label: "ON Tax",     value: -payroll.onTax, color: .red)
                            Divider()
                            PayrollBreakdownRow(label: "Net Pay",    value: payroll.net,    color: .green, bold: true)
                        } header: {
                            Text("CRA 2025 Payroll Breakdown")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existing == nil ? "Add Salary" : "Edit Salary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? SalaryEntry(businessId: businessId, name: "", hours: 0, payRate: 0)
                        entry.businessId = businessId
                        entry.name    = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.hours   = hours
                        entry.payRate = payRate
                        entry.bonus   = bonus
                        entry.notes   = notes.isEmpty ? nil : notes
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              || hours <= 0 || payRate <= 0)
                }
            }
        }
    }
}

private struct PayrollBreakdownRow: View {
    let label: String
    let value: Double
    let color: Color
    var bold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(bold ? .headline : .subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Text(Theme.currency(abs(value)))
                .font(bold ? .headline : .subheadline)
                .foregroundStyle(color)
        }
    }
}

