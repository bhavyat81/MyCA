import Foundation

struct Storage {
    private static let defaults = UserDefaults.standard

    static func salaries(businessId: String, year: Int, month: Int) -> [SalaryEntry] {
        load(forKey: key(prefix: "myca.salaries", businessId: businessId, year: year, month: month))
    }

    static func saveSalaries(_ entries: [SalaryEntry], businessId: String, year: Int, month: Int) {
        save(entries, forKey: key(prefix: "myca.salaries", businessId: businessId, year: year, month: month))
    }

    static func expenses(businessId: String, year: Int, month: Int) -> [ExpenseEntry] {
        load(forKey: key(prefix: "myca.expenses", businessId: businessId, year: year, month: month))
    }

    static func saveExpenses(_ entries: [ExpenseEntry], businessId: String, year: Int, month: Int) {
        save(entries, forKey: key(prefix: "myca.expenses", businessId: businessId, year: year, month: month))
    }

    private static func key(prefix: String, businessId: String, year: Int, month: Int) -> String {
        String(format: "%@.%@.%04d-%02d", prefix, businessId, year, month)
    }

    private static func load<T: Decodable>(forKey key: String) -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }

    private static func save<T: Encodable>(_ values: [T], forKey key: String) {
        if let data = try? JSONEncoder().encode(values) {
            defaults.set(data, forKey: key)
        }
    }
}
