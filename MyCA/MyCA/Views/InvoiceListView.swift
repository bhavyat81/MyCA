import SwiftUI

struct InvoiceListView: View {
    @Environment(Store.self) private var store
    @State private var showingEditor = false
    @State private var editingInvoice: Invoice?
    let business: Business?
    let year: Int?
    let month: Int?
    @State private var selectedBusinessId: String?

    init(business: Business? = nil, year: Int? = nil, month: Int? = nil) {
        self.business = business
        self.year = year
        self.month = month
        _selectedBusinessId = State(initialValue: business?.id)
    }

    private var activeBizId: String {
        business?.id ?? selectedBusinessId ?? Business.all.first?.id ?? "planet-rehab"
    }

    private var filtered: [Invoice] {
        store.invoices.filter { inv in
            let invoiceYear = Calendar.current.component(.year, from: inv.date)
            let invoiceMonth = Calendar.current.component(.month, from: inv.date)
            let bizMatch = inv.businessId == activeBizId
            let yearMatch = year.map { invoiceYear == $0 } ?? true
            let monthMatch = month.map { invoiceMonth == $0 } ?? true
            return bizMatch && yearMatch && monthMatch
        }
    }
    private var scopedMonthName: String? {
        guard let month else { return nil }
        return Calendar.current.monthSymbols[max(1, min(12, month)) - 1]
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(spacing: 0) {
                if let year, let scopedMonthName {
                    AppCard {
                        HStack {
                            Text("\(scopedMonthName) \(year)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                    .padding(16)
                }
                if filtered.isEmpty {
                    Spacer()
                    EmptyState(symbol: "doc.text.fill",
                               title: "No invoices yet.",
                               caption: "Tap + to add.")
                    Spacer()
                } else {
                    List {
                        ForEach(filtered.sorted { $0.date > $1.date }) { inv in
                            let client = store.clients.first { $0.id == inv.clientId }
                            GlassCard(padding: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(inv.number)
                                            .font(.headline).foregroundStyle(.primary)
                                        Text(client?.name ?? "Unknown Client")
                                            .font(.subheadline).foregroundStyle(.secondary)
                                        Text(inv.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(Theme.currency(inv.invoiceTotal))
                                            .font(.headline.weight(.bold)).foregroundStyle(.primary)
                                        Text(inv.paid ? "Paid" : "Unpaid")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(inv.paid ? Color.green : Color.orange)
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .onTapGesture { editingInvoice = inv; showingEditor = true }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.invoices.removeAll { $0.id == inv.id }
                                    store.saveInvoices()
                                } label: { Label("Delete", systemImage: "trash") }
                            }
                        }
                    }
                    .listStyle(.plain).scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Invoices")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editingInvoice = nil; showingEditor = true
                    Haptics.impact(.medium)
                } label: { Image(systemName: "plus.circle.fill").font(.title3) }
            }
        }
        .sheet(isPresented: $showingEditor) {
            InvoiceEditorView(existing: editingInvoice,
                              businessId: activeBizId) { inv in
                if let idx = store.invoices.firstIndex(where: { $0.id == inv.id }) {
                    store.invoices[idx] = inv
                } else {
                    store.invoices.append(inv)
                }
                store.saveInvoices()
                Haptics.success()
            }
            .environment(store)
        }
    }
}

struct InvoiceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let existing: Invoice?
    let businessId: String
    let onSave: (Invoice) -> Void

    @State private var clientId: UUID?
    @State private var number: String
    @State private var date: Date
    @State private var dueDate: Date
    @State private var items: [InvoiceLine]
    @State private var hstRateText: String
    @State private var paid: Bool
    @State private var notes: String

    init(existing: Invoice?, businessId: String, onSave: @escaping (Invoice) -> Void) {
        self.existing = existing; self.businessId = businessId; self.onSave = onSave
        _clientId    = State(initialValue: existing?.clientId)
        _number      = State(initialValue: existing?.number ?? "")
        _date        = State(initialValue: existing?.date ?? Date())
        _dueDate     = State(initialValue: existing?.dueDate ?? Calendar.current.date(byAdding: .day, value: 30, to: Date())!)
        _items       = State(initialValue: existing?.items ?? [InvoiceLine(detail: "", qty: 1, unitPrice: 0)])
        _hstRateText = State(initialValue: existing.map { String($0.hstRate * 100) } ?? "13")
        _paid        = State(initialValue: existing?.paid ?? false)
        _notes       = State(initialValue: existing?.notes ?? "")
    }

    private var hstRate: Double   { (Double(hstRateText) ?? 13) / 100 }
    private var subtotal: Double  { items.reduce(0) { $0 + $1.lineTotal } }
    private var hst: Double       { subtotal * hstRate }
    private var invoiceTotal: Double { subtotal + hst }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                Form {
                    Section("Invoice") {
                        TextField("Invoice Number", text: $number).foregroundStyle(.primary)
                        DatePicker("Date", selection: $date, displayedComponents: .date).foregroundStyle(.primary)
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date).foregroundStyle(.primary)
                        Toggle("Paid", isOn: $paid)
                    }
                    Section("Client") {
                        Picker("Client", selection: $clientId) {
                            Text("Select Client").tag(Optional<UUID>.none)
                            ForEach(store.clients) { c in Text(c.name).tag(Optional(c.id)) }
                        }
                        .foregroundStyle(.primary)
                    }
                    Section("Line Items") {
                        ForEach(Array(items.indices), id: \.self) { idx in
                            VStack(alignment: .leading, spacing: 6) {
                                TextField("Description", text: $items[idx].detail)
                                    .foregroundStyle(.primary)
                                HStack {
                                    TextField("Qty", value: $items[idx].qty, format: .number)
                                        .keyboardType(.decimalPad).frame(width: 60).foregroundStyle(.primary)
                                    Text("×")
                                    TextField("Unit Price", value: $items[idx].unitPrice, format: .currency(code: "CAD"))
                                        .keyboardType(.decimalPad).foregroundStyle(.primary)
                                    Spacer()
                                    Text(Theme.currency(items[idx].lineTotal)).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { items.remove(atOffsets: $0) }
                        Button { items.append(InvoiceLine(detail: "", qty: 1, unitPrice: 0)) } label: {
                            Label("Add Line", systemImage: "plus").foregroundStyle(.primary)
                        }
                    }
                    Section("Totals") {
                        HStack { Text("Subtotal").foregroundStyle(.primary); Spacer(); Text(Theme.currency(subtotal)).foregroundStyle(.secondary) }
                        HStack { Text("HST (\(hstRateText)%)").foregroundStyle(.primary); Spacer(); Text(Theme.currency(hst)).foregroundStyle(.secondary) }
                        HStack { Text("Total").font(.headline).foregroundStyle(.primary); Spacer(); Text(Theme.currency(invoiceTotal)).font(.headline).foregroundStyle(.primary) }
                        TextField("HST Rate %", text: $hstRateText).keyboardType(.decimalPad).foregroundStyle(.primary)
                    }
                    Section("Notes") {
                        TextField("Notes", text: $notes).foregroundStyle(.primary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existing == nil ? "New Invoice" : "Edit Invoice")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let cId = clientId ?? UUID()
                        var inv = existing ?? Invoice(businessId: businessId, clientId: cId,
                                                       number: number, date: date, dueDate: dueDate,
                                                       items: items)
                        inv.clientId = cId; inv.number = number; inv.date = date; inv.dueDate = dueDate
                        inv.items = items; inv.hstRate = hstRate; inv.paid = paid
                        inv.notes = notes.isEmpty ? nil : notes
                        onSave(inv); dismiss()
                    }
                    .disabled(number.isEmpty || items.isEmpty)
                }
            }
        }
    }
}
