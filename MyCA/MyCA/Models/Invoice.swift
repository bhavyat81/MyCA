import Foundation

struct InvoiceLine: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var description: String
    var qty: Double
    var unitPrice: Double
    var lineTotal: Double { qty * unitPrice }

    private enum CodingKeys: String, CodingKey {
        case id, description, qty, unitPrice
    }
}

struct Invoice: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String
    var clientId: UUID
    var number: String
    var date: Date
    var dueDate: Date
    var items: [InvoiceLine]
    var hstRate: Double = 0.13
    var paid: Bool = false
    var notes: String? = nil

    var subtotal: Double { items.reduce(0) { $0 + $1.lineTotal } }
    var hst: Double { subtotal * hstRate }
    var invoiceTotal: Double { subtotal + hst }

    private enum CodingKeys: String, CodingKey {
        case id, businessId, clientId, number, date, dueDate, items, hstRate, paid, notes
    }
}
