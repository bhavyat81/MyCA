import SwiftUI

struct SettingsView: View {
    @Environment(Store.self) private var store
    @State private var showingResetConfirm = false
    @State private var hstRateText: String = ""
    @State private var mileageRateText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Form {
                    // Theme
                    Section("Appearance") {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Button {
                                store.selectedTheme = theme
                                store.saveSettings()
                                Haptics.impact(.light)
                            } label: {
                                HStack {
                                    Text(theme.emoji + " " + theme.displayName)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if store.selectedTheme == theme {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(store.selectedTheme.accent)
                                    }
                                }
                            }
                        }
                    }

                    // HST
                    Section("HST / Tax") {
                        Toggle("HST Registered", isOn: Binding(
                            get: { store.hstRegistered },
                            set: { store.hstRegistered = $0; store.saveSettings() }
                        ))
                        HStack {
                            Text("HST Rate %").foregroundStyle(.primary)
                            Spacer()
                            TextField("13", text: $hstRateText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .foregroundStyle(.primary)
                                .onChange(of: hstRateText) { _, v in
                                    if let rate = Double(v), rate > 0 {
                                        store.hstRate = rate / 100
                                        store.saveSettings()
                                    }
                                }
                        }
                        HStack {
                            Text("Mileage Rate ($/km)").foregroundStyle(.primary)
                            Spacer()
                            TextField("0.72", text: $mileageRateText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .foregroundStyle(.primary)
                                .onChange(of: mileageRateText) { _, v in
                                    if let rate = Double(v), rate > 0 {
                                        store.mileageRate = rate
                                        store.saveSettings()
                                    }
                                }
                        }
                    }

                    // Employees
                    Section("Employees") {
                        NavigationLink {
                            EmployeeRosterView()
                                .environment(store)
                        } label: {
                            Label("Employee Roster", systemImage: "person.2.fill")
                                .foregroundStyle(.primary)
                        }
                    }

                    // Categories
                    Section("Categories") {
                        NavigationLink {
                            CategoriesSettingsView()
                                .environment(store)
                        } label: {
                            Label("Expense Categories", systemImage: "tag.fill")
                                .foregroundStyle(.primary)
                        }
                    }

                    // Vendors & Clients
                    Section("Contacts") {
                        NavigationLink {
                            VendorsView().environment(store)
                        } label: {
                            Label("Vendors", systemImage: "building.2.fill")
                                .foregroundStyle(.primary)
                        }
                        NavigationLink {
                            ClientsView().environment(store)
                        } label: {
                            Label("Clients", systemImage: "person.crop.circle.fill")
                                .foregroundStyle(.primary)
                        }
                    }

                    // Invoices
                    Section("Invoices") {
                        NavigationLink {
                            InvoiceListView().environment(store)
                        } label: {
                            Label("Invoices", systemImage: "doc.text.fill")
                                .foregroundStyle(.primary)
                        }
                    }

                    // Data
                    Section("Data") {
                        Button(role: .destructive) {
                            showingResetConfirm = true
                        } label: {
                            Label("Reset All Data", systemImage: "trash.fill")
                        }
                    }

                    // About
                    Section("About") {
                        HStack {
                            Text("Version").foregroundStyle(.primary)
                            Spacer()
                            Text("2.0 (Build 1)")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Bundle ID").foregroundStyle(.primary)
                            Spacer()
                            Text("com.bhavyat81.myca")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .onAppear {
                hstRateText = String(Int(store.hstRate * 100))
                mileageRateText = String(store.mileageRate)
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
}

// MARK: - Employee Roster
struct EmployeeRosterView: View {
    @Environment(Store.self) private var store
    @State private var showingAdd = false
    @State private var editingEmployee: Employee?

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Group {
                if store.employees.isEmpty {
                    EmptyState(symbol: "person.badge.plus",
                               title: "No Employees",
                               caption: "Tap + to add your first employee")
                } else {
                    List {
                        ForEach(store.employees) { emp in
                            GlassCard(padding: 12) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.purple)
                                        .frame(width: 32, height: 32)
                                        .background(Color.purple.opacity(0.15))
                                        .clipShape(Circle())
                                    VStack(alignment: .leading) {
                                        Text(emp.name).font(.headline).foregroundStyle(.primary)
                                        Text("\(Theme.currency(emp.defaultPayRate))/h · \(emp.role ?? "Employee")")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.employees.removeAll { $0.id == emp.id }
                                    store.saveEmployees()
                                } label: { Label("Delete", systemImage: "trash") }
                            }
                            .onTapGesture { editingEmployee = emp; showingAdd = true }
                        }
                    }
                    .listStyle(.plain).scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Employees")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { editingEmployee = nil; showingAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEmployeeSheet(existing: editingEmployee) { emp in
                if let idx = store.employees.firstIndex(where: { $0.id == emp.id }) {
                    store.employees[idx] = emp
                } else {
                    store.employees.append(emp)
                }
                store.saveEmployees()
            }
            .environment(store)
        }
    }
}

struct AddEmployeeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store
    let existing: Employee?
    let onSave: (Employee) -> Void
    @State private var name: String
    @State private var rateText: String
    @State private var role: String
    @State private var bizId: String

    init(existing: Employee?, onSave: @escaping (Employee) -> Void) {
        self.existing = existing; self.onSave = onSave
        _name     = State(initialValue: existing?.name ?? "")
        _rateText = State(initialValue: existing.map { String($0.defaultPayRate) } ?? "")
        _role     = State(initialValue: existing?.role ?? "")
        _bizId    = State(initialValue: existing?.businessId ?? Business.all.first?.id ?? "planet-rehab")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                Form {
                    Section("Details") {
                        TextField("Name", text: $name).foregroundStyle(.primary)
                        TextField("Pay Rate ($/h)", text: $rateText).keyboardType(.decimalPad).foregroundStyle(.primary)
                        TextField("Role", text: $role).foregroundStyle(.primary)
                        Picker("Business", selection: $bizId) {
                            ForEach(Business.all) { b in Text(b.name).tag(b.id) }
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existing == nil ? "Add Employee" : "Edit Employee")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var emp = existing ?? Employee(businessId: bizId, name: "", defaultPayRate: 0)
                        emp.name = name; emp.defaultPayRate = Double(rateText) ?? 0
                        emp.role = role.isEmpty ? nil : role; emp.businessId = bizId
                        onSave(emp); dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Categories Settings
struct CategoriesSettingsView: View {
    @Environment(Store.self) private var store
    @State private var showingAdd = false

    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            List {
                ForEach(store.categories) { cat in
                    GlassCard(padding: 12) {
                        HStack {
                            Image(systemName: cat.symbolName)
                                .foregroundStyle(Color(hex: cat.colorHex))
                                .frame(width: 32, height: 32)
                                .background(Color(hex: cat.colorHex).opacity(0.15))
                                .clipShape(Circle())
                            Text(cat.name).font(.headline).foregroundStyle(.primary)
                            Spacer()
                            if cat.isDefault {
                                Text("Default").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        if !cat.isDefault {
                            Button(role: .destructive) {
                                store.categories.removeAll { $0.id == cat.id }
                                store.saveCategories()
                            } label: { Label("Delete", systemImage: "trash") }
                        }
                    }
                }
            }
            .listStyle(.plain).scrollContentBackground(.hidden)
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddCategorySheet { cat in
                store.categories.append(cat)
                store.saveCategories()
            }
            .environment(store)
        }
    }
}

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store
    let onSave: (Category) -> Void
    @State private var name = ""
    @State private var symbol = "tag.fill"
    @State private var colorHex = "6366F1"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                Form {
                    Section("New Category") {
                        TextField("Name", text: $name).foregroundStyle(.primary)
                        TextField("SF Symbol name", text: $symbol).foregroundStyle(.primary)
                        TextField("Color Hex", text: $colorHex).foregroundStyle(.primary)
                    }
                    Section("Preview") {
                        HStack {
                            Image(systemName: symbol.isEmpty ? "tag.fill" : symbol)
                                .foregroundStyle(Color(hex: colorHex))
                            Text(name.isEmpty ? "Category" : name).foregroundStyle(.primary)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(Category(name: name, symbolName: symbol, colorHex: colorHex))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Vendors
struct VendorsView: View {
    @Environment(Store.self) private var store
    @State private var showingAdd = false
    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Group {
                if store.vendors.isEmpty {
                    EmptyState(symbol: "building.2.fill", title: "No Vendors", caption: "Tap + to add a vendor")
                } else {
                    List {
                        ForEach(store.vendors) { v in
                            Text(v.name).foregroundStyle(.primary)
                                .listRowBackground(Color.clear)
                                .swipeActions { Button(role: .destructive) {
                                    store.vendors.removeAll { $0.id == v.id }; store.saveVendors()
                                } label: { Label("Delete", systemImage: "trash") } }
                        }
                    }
                    .listStyle(.plain).scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Vendors")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            SimpleNameSheet(title: "Add Vendor") { name in
                store.vendors.append(Vendor(name: name)); store.saveVendors()
            }
            .environment(store)
        }
    }
}

// MARK: - Clients
struct ClientsView: View {
    @Environment(Store.self) private var store
    @State private var showingAdd = false
    var body: some View {
        ZStack {
            LinearGradient(colors: store.selectedTheme.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Group {
                if store.clients.isEmpty {
                    EmptyState(symbol: "person.crop.circle.fill", title: "No Clients", caption: "Tap + to add a client")
                } else {
                    List {
                        ForEach(store.clients) { c in
                            VStack(alignment: .leading) {
                                Text(c.name).font(.headline).foregroundStyle(.primary)
                                if let email = c.email { Text(email).font(.caption).foregroundStyle(.secondary) }
                            }
                            .listRowBackground(Color.clear)
                            .swipeActions { Button(role: .destructive) {
                                store.clients.removeAll { $0.id == c.id }; store.saveClients()
                            } label: { Label("Delete", systemImage: "trash") } }
                        }
                    }
                    .listStyle(.plain).scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("Clients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            SimpleNameSheet(title: "Add Client") { name in
                store.clients.append(Client(name: name)); store.saveClients()
            }
            .environment(store)
        }
    }
}

// MARK: - Simple reusable name sheet
struct SimpleNameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store
    let title: String
    let onSave: (String) -> Void
    @State private var nameText = ""
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: store.selectedTheme.gradientColors,
                               startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                Form {
                    TextField("Name", text: $nameText).foregroundStyle(.primary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(nameText); dismiss() }.disabled(nameText.isEmpty)
                }
            }
        }
    }
}

#Preview {
    SettingsView().environment(Store())
}
