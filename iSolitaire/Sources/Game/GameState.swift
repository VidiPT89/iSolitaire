import Foundation

/// Snapshot of the whole board, used for undo and persistence.
struct GameState: Codable, Equatable {
    var tableau: [[Card]] = Array(repeating: [], count: 7)
    var foundations: [Suit: [Card]] = [:]
    var stock: [Card] = []
    var waste: [Card] = []
    var score: Int = 0
    var moves: Int = 0
    var elapsedSeconds: Int = 0
    var recyclesUsed: Int = 0

    var isWon: Bool {
        foundations.values.reduce(0) { $0 + $1.count } == 52
    }
}
