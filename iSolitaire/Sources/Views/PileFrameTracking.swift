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
