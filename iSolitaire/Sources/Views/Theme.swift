import SwiftUI

enum Theme {
    static let ember = Color(red: 1.00, green: 0.42, blue: 0.11)      // laranja vivo
    static let flame = Color(red: 0.98, green: 0.60, blue: 0.16)      // laranja mais claro
    static let scorched = Color(red: 0.85, green: 0.62, blue: 0.09)   // amarelo queimado
    static let ink = Color(red: 0.06, green: 0.05, blue: 0.05)        // preto quente
    static let charcoal = Color(red: 0.11, green: 0.10, blue: 0.10)
    static let cream = Color(red: 0.98, green: 0.95, blue: 0.90)

    static let gradient = LinearGradient(
        colors: [ink, charcoal, ember.opacity(0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [ember, scorched],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func tableFelt(for scheme: ColorScheme) -> LinearGradient {
        scheme == .dark
        ? LinearGradient(colors: [ink, charcoal], startPoint: .top, endPoint: .bottom)
        : LinearGradient(colors: [Color(red: 0.12, green: 0.1, blue: 0.09), charcoal], startPoint: .top, endPoint: .bottom)
    }
}
