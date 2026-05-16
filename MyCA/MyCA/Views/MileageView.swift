import SwiftUI

struct MileageView: View {
    @Environment(Store.self) private var store
    @State private var showingAdd = false
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

    private var activeBizId: String { business?.id ?? selectedBusinessId ?? Business.all.first?.id ?? "planet-rehab" }

    private var filteredEntries: [MileageEntry] {
        store.mileageEntries.filter {
            let entryYear = Calendar.current.component(.year, from: $0.date)
            let entryMonth = Calendar.current.component(.month, from: $0.date)
            $0.businessId == activeBizId
                && (year.map { entryYear == $0 } ?? true)
                && (month.map { entryMonth == $0 } ?? true)
        }
    }

    private var totalKm: Double       { filteredEntries.reduce(0) { $0 + $1.km } }
    private var totalDeductible: Double { filteredEntries.reduce(0) { $0 + $1.deductible } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let year, let month {
                AppCard {
                    HStack {
                        Text("\(Calendar.current.monthSymbols[month - 1]) \(year)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "Total KM",   value: String(format: "%.1f km", totalKm),
                         symbol: "car.fill", tint: .blue)
                StatCard(title: "Deductible", value: Theme.currency(totalDeductible),
                         symbol: "dollarsign.circle.fill", tint: .green)
            }

            Button {
                showingAdd = true
                Haptics.impact(.medium)
            } label: {
                Label("Log Trip", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if filteredEntries.isEmpty {
                EmptyState(symbol: "car.fill",
                           title: "No mileage yet.",
                           caption: "Tap + to add.")
            } else {
                ForEach(filteredEntries.sorted { $0.date > $1.date }) { entry in
                    GlassCard(padding: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.purpose)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(entry.km, specifier: "%.1f") km")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.primary)
                                Text(Theme.currency(entry.deductible))
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingAdd) {
            AddMileageView(businessId: activeBizId) { entry in
                store.mileageEntries.append(entry)
                store.saveMileage()
                Haptics.success()
            }
            .environment(store)
        }
    }
}

struct AddMileageView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let businessId: String
    let onSave: (MileageEntry) -> Void

    @State private var kmText = ""
    @State private var purpose = ""
    @State private var date = Date()
    @State private var rateText = "0.72"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                Form {
                    Section("Trip Details") {
                        TextField("Purpose", text: $purpose).foregroundStyle(.primary)
                        TextField("Kilometres", text: $kmText).keyboardType(.decimalPad).foregroundStyle(.primary)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .foregroundStyle(.primary)
                        TextField("Rate ($/km)", text: $rateText).keyboardType(.decimalPad).foregroundStyle(.primary)
                    }
                    if let km = Double(kmText), km > 0, let rate = Double(rateText) {
                        Section("Deductible") {
                            HStack {
                                Text("Amount")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(Theme.currency(km * rate)).foregroundStyle(.green)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Log Trip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = MileageEntry(
                            businessId: businessId,
                            date: date,
                            km: Double(kmText) ?? 0,
                            purpose: purpose,
                            rate: Double(rateText) ?? 0.72
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(purpose.isEmpty || (Double(kmText) ?? 0) <= 0)
                }
            }
        }
    }
}
