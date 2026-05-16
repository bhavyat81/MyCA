import Foundation
import Observation

@Observable
final class Store {
    // MARK: - Settings
    var selectedTheme: AppTheme = .midnight
    var hstRate: Double = 0.13
    var hstRegistered: Bool = true
    var mileageRate: Double = 0.72
    var homeOffices: [HomeOffice] = []
    var businessHSTRates: [String: Double] = [:]

    // MARK: - Rosters
    var employees: [Employee] = []
    var categories: [Category] = Category.defaults
    var vendors: [Vendor] = []
    var clients: [Client] = []
    var invoices: [Invoice] = []
    var mileageEntries: [MileageEntry] = []
    var recurringRules: [RecurringRule] = []

    // MARK: - In-memory caches
    private var salariesCache: [String: [SalaryEntry]] = [:]
    private var expensesCache: [String: [ExpenseEntry]] = [:]
    private var revenuesCache: [String: [RevenueEntry]] = [:]

    init() { load() }

    // MARK: - Salary
    func salaries(businessId: String, year: Int, month: Int) -> [SalaryEntry] {
        let key = entryKey("s", businessId: businessId, year: year, month: month)
        if let cached = salariesCache[key] { return cached }
        let loaded = Storage.salaries(businessId: businessId, year: year, month: month)
        salariesCache[key] = loaded
        return loaded
    }

    func upsert(salary: SalaryEntry, businessId: String, year: Int, month: Int) {
        let key = entryKey("s", businessId: businessId, year: year, month: month)
        var list = salaries(businessId: businessId, year: year, month: month)
        if let idx = list.firstIndex(where: { $0.id == salary.id }) {
            list[idx] = salary
        } else {
            list.append(salary)
        }
        salariesCache[key] = list
        Storage.saveSalaries(list, businessId: businessId, year: year, month: month)
    }

    func delete(salary: SalaryEntry, businessId: String, year: Int, month: Int) {
        let key = entryKey("s", businessId: businessId, year: year, month: month)
        var list = salaries(businessId: businessId, year: year, month: month)
        list.removeAll { $0.id == salary.id }
        salariesCache[key] = list
        Storage.saveSalaries(list, businessId: businessId, year: year, month: month)
    }

    // MARK: - Expense
    func expenses(businessId: String, year: Int, month: Int) -> [ExpenseEntry] {
        let key = entryKey("e", businessId: businessId, year: year, month: month)
        if let cached = expensesCache[key] { return cached }
        let loaded = Storage.expenses(businessId: businessId, year: year, month: month)
        expensesCache[key] = loaded
        return loaded
    }

    func upsert(expense: ExpenseEntry, businessId: String, year: Int, month: Int) {
        let key = entryKey("e", businessId: businessId, year: year, month: month)
        var list = expenses(businessId: businessId, year: year, month: month)
        if let idx = list.firstIndex(where: { $0.id == expense.id }) {
            list[idx] = expense
        } else {
            list.append(expense)
        }
        expensesCache[key] = list
        Storage.saveExpenses(list, businessId: businessId, year: year, month: month)
    }

    func delete(expense: ExpenseEntry, businessId: String, year: Int, month: Int) {
        let key = entryKey("e", businessId: businessId, year: year, month: month)
        var list = expenses(businessId: businessId, year: year, month: month)
        list.removeAll { $0.id == expense.id }
        expensesCache[key] = list
        Storage.saveExpenses(list, businessId: businessId, year: year, month: month)
    }

    // MARK: - Revenue
    func revenues(businessId: String, year: Int, month: Int) -> [RevenueEntry] {
        let key = entryKey("r", businessId: businessId, year: year, month: month)
        if let cached = revenuesCache[key] { return cached }
        let loaded: [RevenueEntry] = loadJSON(forKey: "myca.v2.revenues.\(businessId).\(monthStr(year, month))")
        revenuesCache[key] = loaded
        return loaded
    }

    func upsert(revenue: RevenueEntry, businessId: String, year: Int, month: Int) {
        let key = entryKey("r", businessId: businessId, year: year, month: month)
        var list = revenues(businessId: businessId, year: year, month: month)
        if let idx = list.firstIndex(where: { $0.id == revenue.id }) {
            list[idx] = revenue
        } else {
            list.append(revenue)
        }
        revenuesCache[key] = list
        saveJSON(list, forKey: "myca.v2.revenues.\(businessId).\(monthStr(year, month))")
    }

    func delete(revenue: RevenueEntry, businessId: String, year: Int, month: Int) {
        let key = entryKey("r", businessId: businessId, year: year, month: month)
        var list = revenues(businessId: businessId, year: year, month: month)
        list.removeAll { $0.id == revenue.id }
        revenuesCache[key] = list
        saveJSON(list, forKey: "myca.v2.revenues.\(businessId).\(monthStr(year, month))")
    }

    // MARK: - Dashboard aggregates
    func totalRevenue(businessId: String, year: Int, month: Int) -> Double {
        revenues(businessId: businessId, year: year, month: month).reduce(0) { $0 + $1.amount }
    }

    func totalSalaries(businessId: String, year: Int, month: Int) -> Double {
        salaries(businessId: businessId, year: year, month: month).reduce(0) { $0 + $1.gross }
    }

    func totalExpenses(businessId: String, year: Int, month: Int) -> Double {
        expenses(businessId: businessId, year: year, month: month).reduce(0) { $0 + $1.amount }
    }

    func netProfit(businessId: String, year: Int, month: Int) -> Double {
        totalRevenue(businessId: businessId, year: year, month: month)
            - totalSalaries(businessId: businessId, year: year, month: month)
            - totalExpenses(businessId: businessId, year: year, month: month)
    }

    func hstOwed(businessId: String, year: Int, month: Int) -> Double {
        let collected = revenues(businessId: businessId, year: year, month: month)
            .reduce(0) { $0 + $1.hstCollected }
        let paid = expenses(businessId: businessId, year: year, month: month)
            .filter { $0.hstIncluded }
            .reduce(0) { $0 + $1.hstAmount }
        return collected - paid
    }

    // MARK: - Recurring materialization
    func materializeRecurring(year: Int, month: Int) {
        let monthKey = monthStr(year, month)
        for rule in recurringRules where rule.active && rule.startMonth <= monthKey {
            switch rule.kind {
            case .expense:
                if var template = (try? JSONDecoder().decode(ExpenseEntry.self, from: rule.templateJSON)) {
                    var list = expenses(businessId: rule.businessId, year: year, month: month)
                    if !list.contains(where: { $0.notes == "recurring:\(rule.id)" }) {
                        template.id = UUID()
                        template.createdAt = Date()
                        template.notes = "recurring:\(rule.id)"
                        upsert(expense: template, businessId: rule.businessId, year: year, month: month)
                    }
                }
            case .salary:
                if var template = (try? JSONDecoder().decode(SalaryEntry.self, from: rule.templateJSON)) {
                    let list = salaries(businessId: rule.businessId, year: year, month: month)
                    if !list.contains(where: { $0.notes == "recurring:\(rule.id)" }) {
                        template.id = UUID()
                        template.createdAt = Date()
                        template.notes = "recurring:\(rule.id)"
                        upsert(salary: template, businessId: rule.businessId, year: year, month: month)
                    }
                }
            case .revenue:
                if var template = (try? JSONDecoder().decode(RevenueEntry.self, from: rule.templateJSON)) {
                    let list = revenues(businessId: rule.businessId, year: year, month: month)
                    if !list.contains(where: { $0.notes == "recurring:\(rule.id)" }) {
                        template.id = UUID()
                        template.createdAt = Date()
                        template.notes = "recurring:\(rule.id)"
                        upsert(revenue: template, businessId: rule.businessId, year: year, month: month)
                    }
                }
            }
        }
    }

    // MARK: - Persistence helpers
    func saveEmployees()      { saveJSON(employees,     forKey: "myca.v2.employees") }
    func saveCategories()     { saveJSON(categories,    forKey: "myca.v2.categories") }
    func saveVendors()        { saveJSON(vendors,       forKey: "myca.v2.vendors") }
    func saveClients()        { saveJSON(clients,       forKey: "myca.v2.clients") }
    func saveInvoices()       { saveJSON(invoices,      forKey: "myca.v2.invoices") }
    func saveMileage()        { saveJSON(mileageEntries, forKey: "myca.v2.mileage") }
    func saveRecurringRules() { saveJSON(recurringRules, forKey: "myca.v2.recurring") }
    func saveHomeOffices()    { saveJSON(homeOffices,   forKey: "myca.v2.homeOffices") }
    func saveBusinessHSTRates() { saveDictionary(businessHSTRates, forKey: "myca.v2.businessHSTRates") }

    func saveSettings() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "myca.theme")
        UserDefaults.standard.set(hstRate,           forKey: "myca.hstRate")
        UserDefaults.standard.set(hstRegistered,     forKey: "myca.hstRegistered")
        UserDefaults.standard.set(mileageRate,       forKey: "myca.mileageRate")
        saveBusinessHSTRates()
    }

    func resetAllData() {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        employees = []; categories = Category.defaults
        vendors = []; clients = []; invoices = []
        mileageEntries = []; recurringRules = []; homeOffices = []
        businessHSTRates = [:]
        salariesCache = [:]; expensesCache = [:]; revenuesCache = [:]
    }

    func hstRate(for businessId: String) -> Double {
        businessHSTRates[businessId] ?? hstRate
    }

    func setHstRate(_ rate: Double, for businessId: String) {
        businessHSTRates[businessId] = rate
        saveBusinessHSTRates()
    }

    // MARK: - Private
    private func entryKey(_ prefix: String, businessId: String, year: Int, month: Int) -> String {
        "\(prefix).\(businessId).\(monthStr(year, month))"
    }

    private func monthStr(_ year: Int, _ month: Int) -> String {
        String(format: "%04d-%02d", year, month)
    }

    private func load() {
        employees      = loadJSON(forKey: "myca.v2.employees")
        vendors        = loadJSON(forKey: "myca.v2.vendors")
        clients        = loadJSON(forKey: "myca.v2.clients")
        invoices       = loadJSON(forKey: "myca.v2.invoices")
        mileageEntries = loadJSON(forKey: "myca.v2.mileage")
        recurringRules = loadJSON(forKey: "myca.v2.recurring")
        homeOffices    = loadJSON(forKey: "myca.v2.homeOffices")
        businessHSTRates = loadDictionary(forKey: "myca.v2.businessHSTRates")

        let loadedCats: [Category] = loadJSON(forKey: "myca.v2.categories")
        if !loadedCats.isEmpty { categories = loadedCats }

        if let raw = UserDefaults.standard.string(forKey: "myca.theme"),
           let theme = AppTheme(rawValue: raw) { selectedTheme = theme }
        let savedRate = UserDefaults.standard.double(forKey: "myca.hstRate")
        if savedRate > 0 { hstRate = savedRate }
        let savedMileage = UserDefaults.standard.double(forKey: "myca.mileageRate")
        if savedMileage > 0 { mileageRate = savedMileage }
        hstRegistered = UserDefaults.standard.object(forKey: "myca.hstRegistered") as? Bool ?? true
    }

    private func loadJSON<T: Decodable>(forKey key: String) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }

    private func saveJSON<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadDictionary(forKey key: String) -> [String: Double] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let value = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return [:]
        }
        return value
    }

    private func saveDictionary(_ value: [String: Double], forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
