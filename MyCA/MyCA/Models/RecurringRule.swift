import Foundation

struct RecurringRule: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String
    var kind: Kind
    var templateJSON: Data
    var dayOfMonth: Int
    var startMonth: String   // "YYYY-MM"
    var active: Bool = true

    enum Kind: String, Codable {
        case expense, salary, revenue
    }
}
