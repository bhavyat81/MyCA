import Foundation

enum PaymentType: String, Codable, CaseIterable, Hashable {
    case contract
    case payroll
}

struct SalaryEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var businessId: String = ""
    var employeeId: UUID? = nil
    var name: String
    var paymentType: PaymentType = .contract
    var hours: Double
    var payRate: Double
    var bonus: Double = 0
    var notes: String? = nil
    var createdAt: Date = Date()

    var gross: Double { hours * payRate + bonus }
    // backward compat
    var total: Double { gross }

    private enum CodingKeys: String, CodingKey {
        case id, businessId, employeeId, name, paymentType, hours, payRate, bonus, notes, createdAt
    }

    init(
        id: UUID = UUID(),
        businessId: String = "",
        employeeId: UUID? = nil,
        name: String,
        paymentType: PaymentType = .contract,
        hours: Double,
        payRate: Double,
        bonus: Double = 0,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.businessId = businessId
        self.employeeId = employeeId
        self.name = name
        self.paymentType = paymentType
        self.hours = hours
        self.payRate = payRate
        self.bonus = bonus
        self.notes = notes
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        businessId = try container.decodeIfPresent(String.self, forKey: .businessId) ?? ""
        employeeId = try container.decodeIfPresent(UUID.self, forKey: .employeeId)
        name = try container.decode(String.self, forKey: .name)
        paymentType = try container.decodeIfPresent(PaymentType.self, forKey: .paymentType) ?? .contract
        hours = try container.decode(Double.self, forKey: .hours)
        payRate = try container.decode(Double.self, forKey: .payRate)
        bonus = try container.decodeIfPresent(Double.self, forKey: .bonus) ?? 0
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
