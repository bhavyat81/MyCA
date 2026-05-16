import SwiftUI

struct GlobalSettingsView: View {
    @Environment(Store.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetConfirm = false

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Form {
                Section("Theme") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Button {
                            store.selectedTheme = theme
                            store.saveSettings()
                        } label: {
                            HStack {
                                Text(theme.emoji + " " + theme.displayName)
                                Spacer()
                                if store.selectedTheme == theme {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showingResetConfirm = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .confirmationDialog("Reset all data? This cannot be undone.",
                            isPresented: $showingResetConfirm,
                            titleVisibility: .visible) {
            Button("Reset Everything", role: .destructive) {
                store.resetAllData()
                Haptics.warning()
            }
        }
    }
}

struct BusinessSettingsView: View {
    let business: Business
    @Environment(Store.self) private var store
    @State private var hstRateText = ""
    @State private var sqftUsedText = ""
    @State private var sqftTotalText = ""

    private var homeOffice: HomeOffice? {
        store.homeOffices.first { $0.businessId == business.id }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Form {
                Section("Tax") {
                    HStack {
                        Text("HST Rate %")
                        Spacer()
                        TextField("13", text: $hstRateText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    .foregroundStyle(.primary)
                    .onChange(of: hstRateText) { _, value in
                        if let rate = Double(value), rate > 0 {
                            store.setHstRate(rate / 100, for: business.id)
                        }
                    }
                }

                Section("Home Office") {
                    TextField("Sq ft used", text: $sqftUsedText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.primary)
                    TextField("Sq ft total", text: $sqftTotalText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.primary)
                    if let used = Double(sqftUsedText), let total = Double(sqftTotalText), total > 0 {
                        Text("Home office %: \(Int((used / total) * 100))%")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }

                Section("Business Data") {
                    NavigationLink("Employees") { EmployeeRosterView().environment(store) }
                    NavigationLink("Categories") { CategoriesSettingsView().environment(store) }
                    NavigationLink("Vendors") { VendorsView().environment(store) }
                    NavigationLink("Clients") { ClientsView().environment(store) }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .onAppear {
            hstRateText = String(Int(store.hstRate(for: business.id) * 100))
            sqftUsedText = homeOffice.map { String($0.sqftUsed) } ?? ""
            sqftTotalText = homeOffice.map { String($0.sqftTotal) } ?? ""
        }
        .onDisappear {
            guard let used = Double(sqftUsedText), let total = Double(sqftTotalText), used >= 0, total > 0 else {
                return
            }
            let updated = HomeOffice(businessId: business.id, sqftUsed: used, sqftTotal: total)
            if let idx = store.homeOffices.firstIndex(where: { $0.businessId == business.id }) {
                store.homeOffices[idx] = updated
            } else {
                store.homeOffices.append(updated)
            }
            store.saveHomeOffices()
        }
    }
}
