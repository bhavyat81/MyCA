import SwiftUI
import PhotosUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let existing: ExpenseEntry?
    let businessId: String
    let onSave: (ExpenseEntry) -> Void

    @State private var descriptionText: String
    @State private var amountText: String
    @State private var category: String
    @State private var selectedCategoryId: UUID?
    @State private var hstIncluded: Bool
    @State private var hstRateText: String
    @State private var notes: String
    @State private var photoItem: PhotosPickerItem?
    @State private var receiptImageData: Data?

    init(existing: ExpenseEntry?, businessId: String, onSave: @escaping (ExpenseEntry) -> Void) {
        self.existing = existing
        self.businessId = businessId
        self.onSave = onSave
        _descriptionText    = State(initialValue: existing?.description ?? "")
        _amountText         = State(initialValue: existing.map { String($0.amount) } ?? "")
        _category           = State(initialValue: existing?.category ?? "")
        _selectedCategoryId = State(initialValue: existing?.categoryId)
        _hstIncluded        = State(initialValue: existing?.hstIncluded ?? false)
        _hstRateText        = State(initialValue: existing.map { String($0.hstRate * 100) } ?? "13")
        _notes              = State(initialValue: existing?.notes ?? "")
        _receiptImageData   = State(initialValue: existing?.receiptImageData)
    }

    private var amount: Double   { Double(amountText) ?? 0 }
    private var hstRate: Double  { (Double(hstRateText) ?? 13) / 100 }
    private var hstResult: HSTResult { HST.split(total: amount, rate: hstRate) }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Form {
                    Section("Expense Details") {
                        TextField("Description", text: $descriptionText)
                            .foregroundStyle(.primary)
                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                    }

                    Section("HST") {
                        Toggle("HST Included in Amount", isOn: $hstIncluded)
                        if hstIncluded && amount > 0 {
                            HStack {
                                Text("Base Amount")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(Theme.currency(hstResult.base))
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("HST (\(hstRateText)%)")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(Theme.currency(hstResult.hst))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if hstIncluded {
                            TextField("HST Rate %", text: $hstRateText)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(.primary)
                        }
                    }

                    Section("Category") {
                        Picker("Category", selection: $selectedCategoryId) {
                            Text("None").tag(Optional<UUID>.none)
                            ForEach(store.categories) { cat in
                                Label(cat.name, systemImage: cat.symbolName)
                                    .tag(Optional(cat.id))
                            }
                        }
                        .foregroundStyle(.primary)
                    }

                    Section("Receipt") {
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            Label(receiptImageData != nil ? "Change Receipt Photo" : "Attach Receipt Photo",
                                  systemImage: "camera.fill")
                                .foregroundStyle(.primary)
                        }
                        .onChange(of: photoItem) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self) {
                                    receiptImageData = data
                                }
                            }
                        }
                        if receiptImageData != nil {
                            HStack {
                                Text("Receipt attached ✓")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Button("Remove", role: .destructive) { receiptImageData = nil }
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
            .navigationTitle(existing == nil ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? ExpenseEntry(businessId: businessId, description: "", amount: 0)
                        entry.businessId   = businessId
                        entry.description  = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
                        entry.amount       = amount
                        entry.category     = category.isEmpty ? nil : category
                        entry.categoryId   = selectedCategoryId
                        entry.hstIncluded  = hstIncluded
                        entry.hstRate      = hstRate
                        entry.notes        = notes.isEmpty ? nil : notes
                        entry.receiptImageData = receiptImageData
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || amount <= 0)
                }
            }
        }
    }
}

