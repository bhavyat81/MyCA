import Foundation

struct Employee: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String
    var name: String
    var defaultPayRate: Double
    var role: String? = nil
    var sin: String? = nil
}
