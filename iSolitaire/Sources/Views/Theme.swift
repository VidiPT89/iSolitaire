import SwiftUI

enum Theme {
    static let ember = Color(red: 1.00, green: 0.42, blue: 0.11)      // laranja vivo
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

    static func tableFelt(for scheme: ColorScheme) -> some View {
        ZStack {
            if scheme == .dark {
                LinearGradient(colors: [ink, charcoal], startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [ember.opacity(0.10), .clear], center: .center, startRadius: 0, endRadius: 500)
            } else {
                LinearGradient(colors: [Color(red: 0.99, green: 0.93, blue: 0.82), Color(red: 0.97, green: 0.85, blue: 0.64)], startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [ember.opacity(0.08), .clear], center: .center, startRadius: 0, endRadius: 500)
            }
        }
    }

    static func primaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? cream : ink
    }
}
