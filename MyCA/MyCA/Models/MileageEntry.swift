import Foundation

struct MileageEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String
    var date: Date
    var km: Double
    var purpose: String
    var rate: Double = 0.72   // CRA 2025
    var deductible: Double { km * rate }
}
