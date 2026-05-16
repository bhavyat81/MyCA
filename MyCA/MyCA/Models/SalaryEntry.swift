import Foundation

struct SalaryEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var hours: Double
    var payRate: Double
    var createdAt: Date = Date()

    var total: Double { hours * payRate }
}
