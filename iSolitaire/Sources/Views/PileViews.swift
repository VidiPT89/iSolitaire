import SwiftUI

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
        .frame(width: metrics.width, height: metrics.height)
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
    let pileFrames: [PileKind: CGRect]
    let namespace: Namespace.ID
    @Binding var draggingCardID: UUID?
    @State private var dragOffset: CGSize = .zero
    @State private var tapTracker = DoubleTapTracker()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                .frame(width: metrics.width, height: metrics.height)
            if let top = game.state.waste.last {
                CardView(card: top, isHinted: game.hintedCardID == top.id, isDragging: draggingCardID == top.id, width: metrics.width, height: metrics.height)
                    .matchedGeometryEffect(id: top.id, in: namespace)
                    .contentShape(Rectangle())
                    .offset(dragOffset)
                    .zIndex(draggingCardID == top.id ? 1000 : 0)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("board"))
                            .onChanged { value in
                                guard value.translation.width * value.translation.width + value.translation.height * value.translation.height > 36 else { return }
                                draggingCardID = top.id
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let distance = value.translation.width * value.translation.width + value.translation.height * value.translation.height
                                if distance <= 36 {
                                    if tapTracker.registerTap(on: top.id) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            _ = game.tryAutoMoveToFoundation(cardID: top.id, from: .waste)
                                        }
                                    }
                                    dragOffset = .zero
                                    draggingCardID = nil
                                    return
                                }
                                let destination = destinationPile(at: value.location, in: pileFrames, excluding: .waste)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    if let destination {
                                        _ = game.tryMove(cardID: top.id, from: .waste, to: destination)
                                    }
                                    dragOffset = .zero
                                }
                                draggingCardID = nil
                            }
                    )
            }
        }
        .frame(width: metrics.width, height: metrics.height)
    }
}

struct FoundationView: View {
    @ObservedObject var game: GameModel
    let suit: Suit
    let metrics: CardMetrics
    let pileFrames: [PileKind: CGRect]
    let namespace: Namespace.ID
    @Binding var draggingCardID: UUID?
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Theme.scorched.opacity(0.4), lineWidth: 1.5)
                .frame(width: metrics.width, height: metrics.height)
            Text(suit.symbol)
                .font(.system(size: metrics.width * 0.4))
                .foregroundStyle(Theme.scorched.opacity(0.4))
            if let top = game.state.foundations[suit]?.last {
                CardView(card: top, isDragging: draggingCardID == top.id, width: metrics.width, height: metrics.height)
                    .matchedGeometryEffect(id: top.id, in: namespace)
                    .contentShape(Rectangle())
                    .offset(dragOffset)
                    .zIndex(draggingCardID == top.id ? 1000 : 0)
                    .gesture(
                        DragGesture(minimumDistance: 10, coordinateSpace: .named("board"))
                            .onChanged { value in
                                draggingCardID = top.id
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let source = PileKind.foundation(suit)
                                let destination = destinationPile(at: value.location, in: pileFrames, excluding: source)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    if let destination {
                                        _ = game.tryMove(cardID: top.id, from: source, to: destination)
                                    }
                                    dragOffset = .zero
                                }
                                draggingCardID = nil
                            }
                    )
            }
        }
        .frame(width: metrics.width, height: metrics.height)
        .contentShape(Rectangle())
        .reportPileFrame(.foundation(suit))
    }
}

struct TableauColumnView: View {
    @ObservedObject var game: GameModel
    let column: Int
    let metrics: CardMetrics
    let pileFrames: [PileKind: CGRect]
    let namespace: Namespace.ID
    @Binding var draggingCardID: UUID?

    @State private var dragStartIndex: Int?
    @State private var dragOffset: CGSize = .zero
    @State private var tapTracker = DoubleTapTracker()

    var body: some View {
        let pile = game.state.tableau[column]
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                .frame(width: metrics.width, height: metrics.height)

            ForEach(Array(pile.enumerated()), id: \.element.id) { index, card in
                let isBeingDragged = card.isFaceUp && dragStartIndex.map { index >= $0 } ?? false
                CardView(card: card, isHinted: game.hintedCardID == card.id, isDragging: isBeingDragged && draggingCardID == card.id, width: metrics.width, height: metrics.height)
                    .matchedGeometryEffect(id: card.id, in: namespace)
                    .contentShape(Rectangle())
                    .offset(y: CGFloat(index) * metrics.overlap)
                    .offset(isBeingDragged ? dragOffset : .zero)
                    .zIndex(isBeingDragged ? 1000 + Double(index) : Double(index))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("board"))
                            .onChanged { value in
                                guard card.isFaceUp else { return }
                                guard value.translation.width * value.translation.width + value.translation.height * value.translation.height > 36 else { return }
                                dragStartIndex = index
                                draggingCardID = card.id
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                guard card.isFaceUp else { return }
                                let distance = value.translation.width * value.translation.width + value.translation.height * value.translation.height
                                if distance <= 36 {
                                    if tapTracker.registerTap(on: card.id) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            _ = game.tryAutoMoveToFoundation(cardID: card.id, from: .tableau(column))
                                        }
                                    }
                                    dragOffset = .zero
                                    dragStartIndex = nil
                                    draggingCardID = nil
                                    return
                                }
                                let source = PileKind.tableau(column)
                                let destination = destinationPile(at: value.location, in: pileFrames, excluding: source)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    if let destination {
                                        _ = game.tryMove(cardID: card.id, from: source, to: destination)
                                    }
                                    dragOffset = .zero
                                }
                                dragStartIndex = nil
                                draggingCardID = nil
                            }
                    )
            }
        }
        .frame(width: metrics.width, height: metrics.height + CGFloat(max(pile.count - 1, 0)) * metrics.overlap, alignment: .top)
        .contentShape(Rectangle())
        .reportPileFrame(.tableau(column))
    }
}
