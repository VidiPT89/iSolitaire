import SwiftUI
import UniformTypeIdentifiers

struct StockView: View {
    @ObservedObject var game: GameModel
    var body: some View {
        ZStack {
            if game.state.stock.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Theme.cream.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 64, height: 90)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Theme.cream.opacity(0.6))
            } else {
                CardView(card: Card(suit: .spades, rank: .ace, isFaceUp: false))
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
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Theme.cream.opacity(0.15), lineWidth: 1)
                .frame(width: 64, height: 90)
            if let top = game.state.waste.last {
                CardView(card: top, isHinted: game.hintedCardID == top.id)
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
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Theme.scorched.opacity(0.4), lineWidth: 1.5)
                .frame(width: 64, height: 90)
            Text(suit.symbol)
                .font(.system(size: 26))
                .foregroundStyle(Theme.scorched.opacity(0.4))
            if let top = game.state.foundations[suit]?.last {
                CardView(card: top)
                    .onDrag { NSItemProvider(object: "\(top.id.uuidString)|\(PileKind.foundation(suit).encoded)" as NSString) }
            }
        }
        .onDrop(of: [.plainText], delegate: CardDropDelegate(destination: .foundation(suit), game: game))
    }
}

struct TableauColumnView: View {
    @ObservedObject var game: GameModel
    let column: Int
    let cardHeight: CGFloat = 90
    let overlap: CGFloat = 26

    var body: some View {
        let pile = game.state.tableau[column]
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Theme.cream.opacity(0.1), lineWidth: 1)
                .frame(width: 64, height: cardHeight)

            ForEach(Array(pile.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, isHinted: game.hintedCardID == card.id)
                    .offset(y: CGFloat(index) * overlap)
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
        .frame(width: 64, height: cardHeight + CGFloat(max(pile.count - 1, 0)) * overlap, alignment: .top)
        .onDrop(of: [.plainText], delegate: CardDropDelegate(destination: .tableau(column), game: game))
    }
}
