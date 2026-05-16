import Foundation

struct Vendor: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var defaultCategoryId: UUID? = nil
    var notes: String? = nil
}
