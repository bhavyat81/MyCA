import Foundation

struct Client: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var email: String? = nil
    var phone: String? = nil
    var address: String? = nil
}
