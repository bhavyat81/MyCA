import SwiftUI

enum Theme {
    static let backgroundStart = Color(hex: "0F172A")
    static let backgroundMiddle = Color(hex: "312E81")
    static let backgroundEnd = Color(hex: "7C3AED")
    static let accent = Color(hex: "22D3EE")

    static let cardBackground = Color.white.opacity(0.08)
    static let cardCornerRadius: CGFloat = 18

    static let spacingXS: CGFloat = 8
    static let spacingS: CGFloat = 12
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24

    static func titleFont(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 3:
            (r, g, b) = (
                ((int >> 8) & 0xF) * 17,
                ((int >> 4) & 0xF) * 17,
                (int & 0xF) * 17
            )
        default:
            (r, g, b) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
