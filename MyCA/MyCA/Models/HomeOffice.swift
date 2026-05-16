import Foundation

struct HomeOffice: Codable, Hashable {
    var businessId: String
    var sqftUsed: Double
    var sqftTotal: Double
    var percent: Double { sqftTotal > 0 ? sqftUsed / sqftTotal : 0 }
}
