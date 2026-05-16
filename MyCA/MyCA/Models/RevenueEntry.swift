import Foundation

struct RevenueEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String
    var source: String
    var clientId: UUID? = nil
    var amount: Double
    var hstCollected: Double = 0
    var invoiceNumber: String? = nil
    var paid: Bool = true
    var notes: String? = nil
    var createdAt: Date = Date()
}
