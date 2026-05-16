import Foundation
import SwiftUI

struct Business: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let type: String
    let emoji: String
    let colorHex: String

    // backward compat
    var icon: String { emoji }

    var accentColor: Color { Color(hex: colorHex) }

    static let all: [Business] = [
        Business(
            id: "planet-rehab",
            name: "Planet Rehab",
            address: "200 County Court, Brampton",
            type: "Rehab Clinic",
            emoji: "🏥",
            colorHex: "22D3EE"
        ),
        Business(
            id: "83-kennedy",
            name: "83 Kennedy",
            address: "83 Kennedy Rd",
            type: "Real Estate",
            emoji: "🏢",
            colorHex: "A78BFA"
        ),
        Business(
            id: "meltwich",
            name: "Meltwich",
            address: "Meltwich Location",
            type: "Food & Beverage",
            emoji: "🥪",
            colorHex: "FB923C"
        )
    ]
}
