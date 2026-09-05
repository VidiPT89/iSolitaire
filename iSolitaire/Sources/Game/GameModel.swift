import Foundation
import Combine

@MainActor
final class GameModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published var settings: GameSettings
    @Published var hintedCardID: UUID?
    @Published var lastAutoCompleteAvailable: Bool = false
    @Published var wonAnimationTrigger: Int = 0

    private var undoStack: [GameState] = []
    private var timer: Timer?
    private let statsStore = StatsStore()

    init(settings: GameSettings = GameSettings()) {
        self.settings = settings
        self.state = GameState()
        newGame()
    }

    // MARK: - Setup

    func newGame() {
        stopTimer()
        var deck = Card.standardDeck().shuffled()
        var tableau: [[Card]] = Array(repeating: [], count: 7)
        for column in 0..<7 {
            for row in 0...column {
                var card = deck.removeLast()
                card.isFaceUp = (row == column)
                tableau[column].append(card)
            }
        }
        var foundations: [Suit: [Card]] = [:]
        for suit in Suit.allCases { foundations[suit] = [] }

        state = GameState(
            tableau: tableau,
            foundations: foundations,
            stock: deck.map { c in var c = c; c.isFaceUp = false; return c },
            waste: [],
            score: 0,
            moves: 0,
            elapsedSeconds: 0,
            recyclesUsed: 0
        )
        undoStack.removeAll()
        hintedCardID = nil
        lastAutoCompleteAvailable = false
        startTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.state.elapsedSeconds += 1 }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Undo

    private func pushUndo() {
        undoStack.append(state)
        if undoStack.count > 200 { undoStack.removeFirst() }
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        state = previous
        hintedCardID = nil
    }

    var canUndo: Bool { !undoStack.isEmpty }

    // MARK: - Stock / Waste

    func drawFromStock() {
        pushUndo()
        if state.stock.isEmpty {
            if settings.recycleMode == .limited && state.recyclesUsed >= settings.recycleLimit {
                undoStack.removeLast()
                return
            }
            state.stock = state.waste.reversed().map { c in var c = c; c.isFaceUp = false; return c }
            state.waste.removeAll()
            state.recyclesUsed += 1
            state.score = max(0, state.score - 20)
        } else {
            let count = settings.drawMode == .drawOne ? 1 : 3
            for _ in 0..<min(count, state.stock.count) {
                var card = state.stock.removeLast()
                card.isFaceUp = true
                state.waste.append(card)
            }
        }
        state.moves += 1
        hintedCardID = nil
        evaluateAutoComplete()
    }

    // MARK: - Move validation

    private func canPlace(_ card: Card, onTableauTop top: Card?) -> Bool {
        guard let top else { return card.rank == .king }
        return top.isFaceUp && top.suit.isRed != card.suit.isRed && top.rank.rawValue == card.rank.rawValue + 1
    }

    private func canPlace(_ card: Card, onFoundation suit: Suit) -> Bool {
        guard card.suit == suit else { return false }
        let pile = state.foundations[suit] ?? []
        if pile.isEmpty { return card.rank == .ace }
        return pile.last!.rank.rawValue + 1 == card.rank.rawValue
    }

    /// Attempt to move a run of cards starting at `card` from waste or a tableau column to a target pile.
    @discardableResult
    func tryMove(cardID: UUID, from source: PileKind, to destination: PileKind) -> Bool {
        guard let run = extractRun(cardID: cardID, from: source) else { return false }
        guard isValidRun(run) else { return false }

        switch destination {
        case .foundation(let suit):
            guard run.count == 1, canPlace(run[0], onFoundation: suit) else { return false }
        case .tableau(let column):
            let top = state.tableau[column].last
            guard canPlace(run[0], onTableauTop: top) else { return false }
        case .stock, .waste:
            return false
        }

        pushUndo()
        remove(run, from: source)
        append(run, to: destination)
        flipNewTopCardIfNeeded(in: source)
        state.moves += 1
        state.score += scoreDelta(from: source, to: destination)
        hintedCardID = nil
        checkWin()
        evaluateAutoComplete()
        return true
    }

    private func scoreDelta(from source: PileKind, to destination: PileKind) -> Int {
        switch (source, destination) {
        case (.waste, .foundation): return 10
        case (.tableau, .foundation): return 10
        case (.foundation, .tableau): return -15
        case (.waste, .tableau): return 5
        default: return 0
        }
    }

    private func extractRun(cardID: UUID, from source: PileKind) -> [Card]? {
        switch source {
        case .waste:
            guard let card = state.waste.last, card.id == cardID else { return nil }
            return [card]
        case .foundation(let suit):
            guard let card = state.foundations[suit]?.last, card.id == cardID else { return nil }
            return [card]
        case .tableau(let column):
            let pile = state.tableau[column]
            guard let idx = pile.firstIndex(where: { $0.id == cardID }) else { return nil }
            guard pile[idx].isFaceUp else { return nil }
            return Array(pile[idx...])
        case .stock:
            return nil
        }
    }

    private func isValidRun(_ run: [Card]) -> Bool {
        guard run.count > 1 else { return true }
        for i in 0..<run.count - 1 {
            let a = run[i], b = run[i + 1]
            if a.suit.isRed == b.suit.isRed { return false }
            if a.rank.rawValue != b.rank.rawValue + 1 { return false }
        }
        return true
    }

    private func remove(_ run: [Card], from source: PileKind) {
        switch source {
        case .waste:
            state.waste.removeLast(run.count)
        case .foundation(let suit):
            state.foundations[suit]?.removeLast(run.count)
        case .tableau(let column):
            state.tableau[column].removeLast(run.count)
        case .stock:
            break
        }
    }

    private func append(_ run: [Card], to destination: PileKind) {
        switch destination {
        case .foundation(let suit):
            state.foundations[suit, default: []].append(contentsOf: run)
        case .tableau(let column):
            state.tableau[column].append(contentsOf: run)
        case .waste, .stock:
            break
        }
    }

    private func flipNewTopCardIfNeeded(in source: PileKind) {
        if case .tableau(let column) = source {
            if var last = state.tableau[column].last, !last.isFaceUp {
                last.isFaceUp = true
                state.tableau[column][state.tableau[column].count - 1] = last
                state.score += 5
            }
        }
    }

    // MARK: - Double tap auto move to foundation

    @discardableResult
    func tryAutoMoveToFoundation(cardID: UUID, from source: PileKind) -> Bool {
        guard let run = extractRun(cardID: cardID, from: source), run.count == 1 else { return false }
        let card = run[0]
        return tryMove(cardID: cardID, from: source, to: .foundation(card.suit))
    }

    // MARK: - Hint

    func requestHint() {
        for column in state.tableau.indices {
            guard let top = state.tableau[column].last, top.isFaceUp else { continue }
            if canPlace(top, onFoundation: top.suit) {
                hintedCardID = top.id
                return
            }
        }
        if let top = state.waste.last, canPlace(top, onFoundation: top.suit) {
            hintedCardID = top.id
            return
        }
        for column in state.tableau.indices {
            guard let top = state.tableau[column].last, top.isFaceUp else { continue }
            for other in state.tableau.indices where other != column {
                if canPlace(top, onTableauTop: state.tableau[other].last) {
                    hintedCardID = top.id
                    return
                }
            }
        }
        if let top = state.waste.last {
            for column in state.tableau.indices {
                if canPlace(top, onTableauTop: state.tableau[column].last) {
                    hintedCardID = top.id
                    return
                }
            }
        }
        hintedCardID = nil
    }

    // MARK: - Auto-complete

    private func evaluateAutoComplete() {
        let allFaceUp = state.tableau.allSatisfy { column in column.allSatisfy { $0.isFaceUp } }
        lastAutoCompleteAvailable = allFaceUp && state.stock.isEmpty
    }

    func autoComplete() {
        guard lastAutoCompleteAvailable else { return }
        pushUndo()
        var progressed = true
        while progressed {
            progressed = false
            if let top = state.waste.last, canPlace(top, onFoundation: top.suit) {
                let card = state.waste.removeLast()
                state.foundations[card.suit, default: []].append(card)
                state.score += 10
                progressed = true
                continue
            }
            for column in state.tableau.indices {
                if let top = state.tableau[column].last, top.isFaceUp, canPlace(top, onFoundation: top.suit) {
                    state.tableau[column].removeLast()
                    state.foundations[top.suit, default: []].append(top)
                    state.score += 10
                    progressed = true
                }
            }
        }
        checkWin()
    }

    // MARK: - Win

    private func checkWin() {
        guard state.isWon else { return }
        stopTimer()
        wonAnimationTrigger += 1
        statsStore.recordWin(time: state.elapsedSeconds, moves: state.moves, score: state.score)
    }

    func recordLossIfAbandoned() {
        guard !state.isWon else { return }
        statsStore.recordAbandon()
    }
}
