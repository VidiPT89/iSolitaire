import SwiftUI

/// Tracks each pile's on-screen frame (in the shared "board" coordinate space) so a
/// SwiftUI-native DragGesture can hit-test a drop location itself, without UIKit's
/// drag & drop system (which triggers the "_UIPlatterView ... not supported" runtime
/// warning when used from a UIHostingController).
struct PileFramePreferenceKey: PreferenceKey {
    static var defaultValue: [PileKind: CGRect] = [:]
    static func reduce(value: inout [PileKind: CGRect], nextValue: () -> [PileKind: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    func reportPileFrame(_ kind: PileKind) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(key: PileFramePreferenceKey.self, value: [kind: geo.frame(in: .named("board"))])
            }
        )
    }
}

func destinationPile(at location: CGPoint, in frames: [PileKind: CGRect], excluding source: PileKind) -> PileKind? {
    for (kind, frame) in frames where kind != source && frame.contains(location) {
        return kind
    }
    return nil
}

/// Detects a double-tap from two consecutive drag-gesture "taps" (near-zero movement)
/// on the same card, without using SwiftUI's `TapGesture`. A `TapGesture` combined with
/// a `DragGesture` on the same view — even via `.exclusively(before:)` — makes SwiftUI
/// hold off starting the drag until it can rule out a second tap, which reads as a
/// noticeable delay/lag on every ordinary drag. Tracking taps manually keeps the drag
/// instantaneous.
struct DoubleTapTracker {
    private var lastTapCardID: UUID?
    private var lastTapDate: Date?

    /// Call from a drag gesture's `onEnded` when the release barely moved. Returns
    /// `true` if this completes a double-tap on the same card.
    mutating func registerTap(on cardID: UUID) -> Bool {
        if lastTapCardID == cardID, let previous = lastTapDate, Date().timeIntervalSince(previous) < 0.35 {
            lastTapCardID = nil
            lastTapDate = nil
            return true
        }
        lastTapCardID = cardID
        lastTapDate = Date()
        return false
    }
}
