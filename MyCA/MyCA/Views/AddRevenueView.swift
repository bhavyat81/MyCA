import SwiftUI

struct AddRevenueView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let existing: RevenueEntry?
    let businessId: String
    let onSave: (RevenueEntry) -> Void

    @State private var source: String
    @State private var amountText: String
    @State private var hstIncluded: Bool
    @State private var hstRateText: String
    @State private var paid: Bool
    @State private var invoiceNumber: String
    @State private var notes: String

    init(existing: RevenueEntry?, businessId: String, onSave: @escaping (RevenueEntry) -> Void) {
        self.existing = existing
        self.businessId = businessId
        self.onSave = onSave
        _source        = State(initialValue: existing?.source ?? "")
        _amountText    = State(initialValue: existing.map { String($0.amount) } ?? "")
        _hstIncluded   = State(initialValue: existing != nil ? existing!.hstCollected > 0 : true)
        _hstRateText   = State(initialValue: "13")
        _paid          = State(initialValue: existing?.paid ?? true)
        _invoiceNumber = State(initialValue: existing?.invoiceNumber ?? "")
        _notes         = State(initialValue: existing?.notes ?? "")
    }

    private var amount: Double  { Double(amountText) ?? 0 }
    private var hstRate: Double { (Double(hstRateText) ?? 13) / 100 }
    private var hstCalc: Double { hstIncluded ? amount * hstRate : 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Form {
                    Section("Revenue Details") {
                        TextField("Source / Client Name", text: $source)
                            .foregroundStyle(.primary)
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                        Toggle("Mark as Paid", isOn: $paid)
                        TextField("Invoice Number (optional)", text: $invoiceNumber)
                            .foregroundStyle(.primary)
                    }

                    Section("HST") {
                        Toggle("Collect HST", isOn: $hstIncluded)
                        if hstIncluded {
                            TextField("HST Rate %", text: $hstRateText)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(.primary)
                            if amount > 0 {
                                HStack {
                                    Text("HST Collected")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text(Theme.currency(hstCalc))
                                        .foregroundStyle(.secondary)
                                }
                                HStack {
                                    Text("Total (incl. HST)")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text(Theme.currency(amount + hstCalc))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Section("Notes") {
                        TextField("Notes (optional)", text: $notes)
                            .foregroundStyle(.primary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existing == nil ? "Add Revenue" : "Edit Revenue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? RevenueEntry(businessId: businessId, source: "", amount: 0)
                        entry.businessId    = businessId
                        entry.source        = source.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.amount        = amount
                        entry.hstCollected  = hstCalc
                        entry.paid          = paid
                        entry.invoiceNumber = invoiceNumber.isEmpty ? nil : invoiceNumber
                        entry.notes         = notes.isEmpty ? nil : notes
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || amount <= 0)
                }
            }
        }
    }
}
