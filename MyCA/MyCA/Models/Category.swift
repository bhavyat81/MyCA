import Foundation

struct Category: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var symbolName: String
    var colorHex: String
    var isDefault: Bool = false

    static let defaults: [Category] = [
        Category(id: UUID(), name: "Rent", symbolName: "house.fill", colorHex: "6366F1", isDefault: true),
        Category(id: UUID(), name: "Utilities", symbolName: "bolt.fill", colorHex: "F59E0B", isDefault: true),
        Category(id: UUID(), name: "Supplies", symbolName: "cart.fill", colorHex: "10B981", isDefault: true),
        Category(id: UUID(), name: "Marketing", symbolName: "megaphone.fill", colorHex: "EC4899", isDefault: true),
        Category(id: UUID(), name: "Payroll", symbolName: "person.2.fill", colorHex: "8B5CF6", isDefault: true),
        Category(id: UUID(), name: "Travel", symbolName: "car.fill", colorHex: "3B82F6", isDefault: true),
        Category(id: UUID(), name: "Meals", symbolName: "fork.knife", colorHex: "F97316", isDefault: true),
        Category(id: UUID(), name: "Insurance", symbolName: "shield.fill", colorHex: "14B8A6", isDefault: true),
        Category(id: UUID(), name: "Professional Fees", symbolName: "doc.text.fill", colorHex: "F43F5E", isDefault: true),
        Category(id: UUID(), name: "Other", symbolName: "ellipsis.circle.fill", colorHex: "6B7280", isDefault: true),
    ]
}
