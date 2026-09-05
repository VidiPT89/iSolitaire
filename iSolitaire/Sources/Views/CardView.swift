import SwiftUI

struct CardView: View {
    let card: Card
    var isHinted: Bool = false
    var width: CGFloat = 64
    var height: CGFloat = 90

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(card.isFaceUp ? AnyShapeStyle(Theme.cream) : AnyShapeStyle(Theme.accentGradient))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(isHinted ? Theme.scorched : Color.black.opacity(0.25), lineWidth: isHinted ? 3 : 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)

            if card.isFaceUp {
                VStack(spacing: 2) {
                    HStack {
                        Text(card.rank.label)
                            .font(.system(size: width * 0.22, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    Spacer()
                    Text(card.suit.symbol)
                        .font(.system(size: width * 0.38))
                    Spacer()
                    HStack {
                        Spacer()
                        Text(card.rank.label)
                            .font(.system(size: width * 0.22, weight: .bold, design: .rounded))
                    }
                }
                .padding(6)
                .foregroundStyle(card.suit.isRed ? Theme.ember : Theme.ink)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Theme.cream.opacity(0.5), lineWidth: 1.5)
                    .padding(6)
            }
        }
        .frame(width: width, height: height)
        .scaleEffect(isHinted ? 1.06 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: card.isFaceUp)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHinted)
    }
}
