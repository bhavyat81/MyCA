import Foundation

struct Business: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let type: String
    let icon: String

    static let all: [Business] = [
        Business(
            id: "planet-rehab",
            name: "Planet Rehab",
            address: "200 County Court, Brampton",
            type: "Rehab Clinic",
            icon: "🏥"
        ),
        Business(
            id: "83-kennedy",
            name: "83 Kennedy",
            address: "83 Kennedy",
            type: "Business",
            icon: "🏢"
        ),
        Business(
            id: "meltwich",
            name: "Meltwich",
            address: "Meltwich",
            type: "Business",
            icon: "🥪"
        )
    ]
}
