import Foundation

enum Suit: String, CaseIterable, Codable {
    case hearts, diamonds, clubs, spades

    var symbol: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }

    var isRed: Bool {
        self == .hearts || self == .diamonds
    }
}

enum Rank: Int, CaseIterable, Codable {
    case ace = 1, two, three, four, five, six, seven,
         eight, nine, ten, jack, queen, king

    var label: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return "\(rawValue)"
        }
    }
}

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let suit: Suit
    let rank: Rank
    var isFaceUp: Bool

    init(suit: Suit, rank: Rank, isFaceUp: Bool = false) {
        self.id = UUID()
        self.suit = suit
        self.rank = rank
        self.isFaceUp = isFaceUp
    }

    static func standardDeck() -> [Card] {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        return deck
    }
}

enum PileKind: Hashable, Codable {
    case stock
    case waste
    case foundation(Suit)
    case tableau(Int)
}
