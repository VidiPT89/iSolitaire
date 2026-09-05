import SwiftUI

/// Card proportions shared by every pile so the board scales to fit any screen width.
struct CardMetrics {
    let width: CGFloat
    var height: CGFloat { width * 90 / 64 }
    var overlap: CGFloat { width * 26 / 64 }
}

private let tapMoveThresholdSquared: CGFloat = 36 // ~6pt

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
    @Binding var dragPreview: DragPreview?
    @State private var tapTracker = DoubleTapTracker()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                .frame(width: metrics.width, height: metrics.height)
            if let top = game.state.waste.last {
                let isBeingDragged = dragPreview?.source == .waste && dragPreview?.cards.first?.id == top.id
                CardView(card: top, isHinted: game.hintedCardID == top.id, width: metrics.width, height: metrics.height)
                    .opacity(isBeingDragged ? 0 : 1)
                    .transition(.asymmetric(insertion: .scale(scale: 0.6).combined(with: .opacity), removal: .opacity))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("board"))
                            .onChanged { value in
                                guard value.translation.width * value.translation.width + value.translation.height * value.translation.height > tapMoveThresholdSquared else { return }
                                if dragPreview == nil {
                                    dragPreview = DragPreview(cards: [top], source: .waste, location: value.location, metrics: metrics)
                                } else {
                                    dragPreview?.location = value.location
                                }
                            }
                            .onEnded { value in
                                let distance = value.translation.width * value.translation.width + value.translation.height * value.translation.height
                                if distance <= tapMoveThresholdSquared {
                                    if tapTracker.registerTap(on: top.id) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            _ = game.tryAutoMoveToFoundation(cardID: top.id, from: .waste)
                                        }
                                    }
                                    dragPreview = nil
                                    return
                                }
                                let destination = destinationPile(at: value.location, in: pileFrames, excluding: .waste)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    if let destination {
                                        _ = game.tryMove(cardID: top.id, from: .waste, to: destination)
                                    }
                                }
                                dragPreview = nil
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
    @Binding var dragPreview: DragPreview?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Theme.scorched.opacity(0.4), lineWidth: 1.5)
                .frame(width: metrics.width, height: metrics.height)
            Text(suit.symbol)
                .font(.system(size: metrics.width * 0.4))
                .foregroundStyle(Theme.scorched.opacity(0.4))
            if let top = game.state.foundations[suit]?.last {
                let source = PileKind.foundation(suit)
                let isBeingDragged = dragPreview?.source == source && dragPreview?.cards.first?.id == top.id
                CardView(card: top, width: metrics.width, height: metrics.height)
                    .opacity(isBeingDragged ? 0 : 1)
                    .transition(.asymmetric(insertion: .scale(scale: 0.6).combined(with: .opacity), removal: .opacity))
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 4, coordinateSpace: .named("board"))
                            .onChanged { value in
                                if dragPreview == nil {
                                    dragPreview = DragPreview(cards: [top], source: source, location: value.location, metrics: metrics)
                                } else {
                                    dragPreview?.location = value.location
                                }
                            }
                            .onEnded { value in
                                let destination = destinationPile(at: value.location, in: pileFrames, excluding: source)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    if let destination {
                                        _ = game.tryMove(cardID: top.id, from: source, to: destination)
                                    }
                                }
                                dragPreview = nil
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
    @Binding var dragPreview: DragPreview?
    @State private var tapTracker = DoubleTapTracker()

    var body: some View {
        let pile = game.state.tableau[column]
        let source = PileKind.tableau(column)
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                .frame(width: metrics.width, height: metrics.height)

            ForEach(Array(pile.enumerated()), id: \.element.id) { index, card in
                let isBeingDragged = card.isFaceUp
                    && dragPreview?.source == source
                    && (dragPreview?.cards.contains { $0.id == card.id } ?? false)
                CardView(card: card, isHinted: game.hintedCardID == card.id, width: metrics.width, height: metrics.height)
                    .opacity(isBeingDragged ? 0 : 1)
                    .transition(.asymmetric(insertion: .scale(scale: 0.6).combined(with: .opacity), removal: .opacity))
                    .contentShape(Rectangle())
                    .offset(y: CGFloat(index) * metrics.overlap)
                    .zIndex(Double(index))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("board"))
                            .onChanged { value in
                                guard card.isFaceUp else { return }
                                guard value.translation.width * value.translation.width + value.translation.height * value.translation.height > tapMoveThresholdSquared else { return }
                                if dragPreview == nil {
                                    dragPreview = DragPreview(cards: Array(pile[index...]), source: source, location: value.location, metrics: metrics)
                                } else {
                                    dragPreview?.location = value.location
                                }
                            }
                            .onEnded { value in
                                guard card.isFaceUp else { return }
                                let distance = value.translation.width * value.translation.width + value.translation.height * value.translation.height
                                if distance <= tapMoveThresholdSquared {
                                    if tapTracker.registerTap(on: card.id) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            _ = game.tryAutoMoveToFoundation(cardID: card.id, from: source)
                                        }
                                    }
                                    dragPreview = nil
                                    return
                                }
                                let destination = destinationPile(at: value.location, in: pileFrames, excluding: source)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    if let destination {
                                        _ = game.tryMove(cardID: card.id, from: source, to: destination)
                                    }
                                }
                                dragPreview = nil
                            }
                    )
            }
        }
        .frame(width: metrics.width, height: metrics.height + CGFloat(max(pile.count - 1, 0)) * metrics.overlap, alignment: .top)
        .contentShape(Rectangle())
        .reportPileFrame(source)
    }
}

/// Renders whichever card (or run of cards) is currently being dragged, in a single
/// board-level overlay so it always paints above every pile regardless of which
/// column it's currently hovering over.
struct DragPreviewOverlay: View {
    let preview: DragPreview

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(preview.cards.enumerated()), id: \.element.id) { index, card in
                CardView(card: card, isDragging: true, width: preview.metrics.width, height: preview.metrics.height)
                    .offset(y: CGFloat(index) * preview.metrics.overlap)
            }
        }
        .frame(width: preview.metrics.width, height: preview.metrics.height, alignment: .top)
        .position(preview.location)
        .allowsHitTesting(false)
    }
}
