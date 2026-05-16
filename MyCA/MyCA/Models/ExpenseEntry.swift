import Foundation

struct ExpenseEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var description: String
    var amount: Double
    var category: String?
    var createdAt: Date = Date()
}
