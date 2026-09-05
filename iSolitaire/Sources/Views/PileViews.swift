import SwiftUI
import UniformTypeIdentifiers

/// Card proportions shared by every pile so the board scales to fit any screen width.
struct CardMetrics {
    let width: CGFloat
    var height: CGFloat { width * 90 / 64 }
    var overlap: CGFloat { width * 26 / 64 }
}

struct StockView: View {
    @ObservedObject var game: GameModel
    let metrics: CardMetrics
    var body: some View {
        ZStack {
            if game.state.stock.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.primary.opacity(0.4), lineWidth: 1.5)
                    .frame(width: metrics.width, height: metrics.height)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Color.primary.opacity(0.6))
            } else {
                CardView(card: Card(suit: .spades, rank: .ace, isFaceUp: false), width: metrics.width, height: metrics.height)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                game.drawFromStock()
            }
        }
    }
}

struct WasteView: View {
    @ObservedObject var game: GameModel
    let metrics: CardMetrics
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                .frame(width: metrics.width, height: metrics.height)
            if let top = game.state.waste.last {
                CardView(card: top, isHinted: game.hintedCardID == top.id, width: metrics.width, height: metrics.height)
                    .onDrag {
                        NSItemProvider(object: "\(top.id.uuidString)|\(PileKind.waste.encoded)" as NSString)
                    }
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            _ = game.tryAutoMoveToFoundation(cardID: top.id, from: .waste)
                        }
                    }
            }
        }
    }
}

struct FoundationView: View {
    @ObservedObject var game: GameModel
    let suit: Suit
    let metrics: CardMetrics
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Theme.scorched.opacity(0.4), lineWidth: 1.5)
                .frame(width: metrics.width, height: metrics.height)
            Text(suit.symbol)
                .font(.system(size: metrics.width * 0.4))
                .foregroundStyle(Theme.scorched.opacity(0.4))
            if let top = game.state.foundations[suit]?.last {
                CardView(card: top, width: metrics.width, height: metrics.height)
                    .onDrag { NSItemProvider(object: "\(top.id.uuidString)|\(PileKind.foundation(suit).encoded)" as NSString) }
            }
        }
        .onDrop(of: [.plainText], delegate: CardDropDelegate(destination: .foundation(suit), game: game))
    }
}

struct TableauColumnView: View {
    @ObservedObject var game: GameModel
    let column: Int
    let metrics: CardMetrics

    var body: some View {
        let pile = game.state.tableau[column]
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                .frame(width: metrics.width, height: metrics.height)

            ForEach(Array(pile.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, isHinted: game.hintedCardID == card.id, width: metrics.width, height: metrics.height)
                    .offset(y: CGFloat(index) * metrics.overlap)
                    .zIndex(Double(index))
                    .onDrag {
                        card.isFaceUp
                        ? NSItemProvider(object: "\(card.id.uuidString)|\(PileKind.tableau(column).encoded)" as NSString)
                        : NSItemProvider()
                    }
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            _ = game.tryAutoMoveToFoundation(cardID: card.id, from: .tableau(column))
                        }
                    }
            }
        }
        .frame(width: metrics.width, height: metrics.height + CGFloat(max(pile.count - 1, 0)) * metrics.overlap, alignment: .top)
        .onDrop(of: [.plainText], delegate: CardDropDelegate(destination: .tableau(column), game: game))
    }
}
