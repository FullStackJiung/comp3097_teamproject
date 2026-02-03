import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64

        switch cleaned.count {
        case 6:
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        default:
            r = 128
            g = 128
            b = 128
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }
}

enum AppColors {
    static let background = Color(hex: "FEF5F0")
    static let backgroundAlt = Color(hex: "FEF9F3")
    static let backgroundDark = Color(hex: "2D2838")
    static let surface = Color.white
    static let surfaceDark = Color(hex: "3A3148")
    static let accent = Color(hex: "B8A0D9")
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
}
