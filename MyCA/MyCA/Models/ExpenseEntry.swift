import Foundation

struct ExpenseEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String = ""
    var description: String
    var amount: Double
    var category: String?
    var categoryId: UUID?
    var vendorId: UUID?
    var isTaxDeductible: Bool = true
    var hstIncluded: Bool = false
    var hstRate: Double = 0.13
    var receiptImageData: Data?
    var notes: String?
    var createdAt: Date = Date()

    var hstAmount: Double { hstIncluded ? amount - (amount / (1 + hstRate)) : 0 }
    var preTaxAmount: Double { hstIncluded ? amount - hstAmount : amount }
}
