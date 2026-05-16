import SwiftUI

// MARK: - App Theme Enum
enum AppTheme: String, CaseIterable, Codable {
    case midnight = "midnight"
    case ocean    = "ocean"
    case sunset   = "sunset"

    var displayName: String {
        switch self {
        case .midnight: return "Midnight"
        case .ocean:    return "Ocean"
        case .sunset:   return "Sunset"
        }
    }

    var emoji: String {
        switch self {
        case .midnight: return "🌌"
        case .ocean:    return "🌊"
        case .sunset:   return "🌇"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .midnight: return [Color(hex: "0F172A"), Color(hex: "312E81"), Color(hex: "7C3AED")]
        case .ocean:    return [Color(hex: "0F3460"), Color(hex: "0E7490"), Color(hex: "06B6D4")]
        case .sunset:   return [Color(hex: "4A0010"), Color(hex: "C2410C"), Color(hex: "F59E0B")]
        }
    }

    var accent: Color {
        switch self {
        case .midnight: return Color(hex: "22D3EE")
        case .ocean:    return Color(hex: "67E8F9")
        case .sunset:   return Color(hex: "FCD34D")
        }
    }

    var textPrimary: Color    { .white }
    var textSecondary: Color  { Color.white.opacity(0.75) }
    var textOnCard: Color     { Color.primary }
}

// MARK: - Static Theme Constants
enum Theme {
    static let backgroundStart  = Color(hex: "0F172A")
    static let backgroundMiddle = Color(hex: "312E81")
    static let backgroundEnd    = Color(hex: "7C3AED")
    static let accent           = Color(hex: "22D3EE")

    static let cardBackground   = Color.white.opacity(0.08)
    static let cardCornerRadius: CGFloat = 20

    static let spacingXS: CGFloat = 8
    static let spacingS: CGFloat  = 12
    static let spacingM: CGFloat  = 16
    static let spacingL: CGFloat  = 24

    static func titleFont(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func currency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.locale = Locale(identifier: "en_CA")
        fmt.maximumFractionDigits = 2
        return fmt.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Color hex init
extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 3:
            (r, g, b) = (((int >> 8) & 0xF) * 17,
                         ((int >> 4) & 0xF) * 17,
                         (int & 0xF) * 17)
        default:
            (r, g, b) = ((int >> 16) & 0xFF,
                         (int >> 8) & 0xFF,
                         int & 0xFF)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: 1)
    }

    var hexString: String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "000000"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}

// MARK: - Haptics helper
enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

