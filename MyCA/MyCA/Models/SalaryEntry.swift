import Foundation

struct SalaryEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String = ""
    var employeeId: UUID? = nil
    var name: String
    var hours: Double
    var payRate: Double
    var bonus: Double = 0
    var notes: String? = nil
    var createdAt: Date = Date()

    var gross: Double { hours * payRate + bonus }
    // backward compat
    var total: Double { gross }
}
