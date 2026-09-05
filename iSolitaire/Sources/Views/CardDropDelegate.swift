import SwiftUI
import UniformTypeIdentifiers

struct CardDropDelegate: DropDelegate {
    let destination: PileKind
    let game: GameModel
    var onDropSucceeded: () -> Void = {}

    func performDrop(info: DropInfo) -> Bool {
        guard let provider = info.itemProviders(for: [.plainText]).first else { return false }
        provider.loadObject(ofClass: NSString.self) { object, _ in
            guard let string = object as? String,
                  let uuid = UUID(uuidString: string.components(separatedBy: "|").first ?? "") else { return }
            let sourceRaw = string.components(separatedBy: "|").last ?? ""
            guard let source = PileKind.decode(sourceRaw) else { return }
            Task { @MainActor in
                if game.tryMove(cardID: uuid, from: source, to: destination) {
                    onDropSucceeded()
                }
            }
        }
        return true
    }
}

extension PileKind {
    var encoded: String {
        switch self {
        case .stock: return "stock"
        case .waste: return "waste"
        case .foundation(let suit): return "foundation:\(suit.rawValue)"
        case .tableau(let column): return "tableau:\(column)"
        }
    }

    static func decode(_ raw: String) -> PileKind? {
        if raw == "stock" { return .stock }
        if raw == "waste" { return .waste }
        if raw.hasPrefix("foundation:"), let suit = Suit(rawValue: String(raw.dropFirst("foundation:".count))) {
            return .foundation(suit)
        }
        if raw.hasPrefix("tableau:"), let column = Int(raw.dropFirst("tableau:".count)) {
            return .tableau(column)
        }
        return nil
    }
}
