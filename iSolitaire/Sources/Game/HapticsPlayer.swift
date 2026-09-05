import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Light haptic feedback on successful actions. iPhone only — a no-op on iPad, which has no Taptic Engine.
final class HapticsPlayer {
    #if canImport(UIKit)
    private let impact = UIImpactFeedbackGenerator(style: .light)
    private let notification = UINotificationFeedbackGenerator()
    #endif

    func cardDrawn() {
        #if canImport(UIKit)
        impact.impactOccurred(intensity: 0.5)
        #endif
    }

    func moveSucceeded() {
        #if canImport(UIKit)
        impact.impactOccurred()
        #endif
    }

    func gameWon() {
        #if canImport(UIKit)
        notification.notificationOccurred(.success)
        #endif
    }
}
