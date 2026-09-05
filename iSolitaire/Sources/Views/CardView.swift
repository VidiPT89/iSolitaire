import SwiftUI

struct CardView: View {
    let card: Card
    var isHinted: Bool = false
    var isDragging: Bool = false
    var width: CGFloat = 64
    var height: CGFloat = 90

    @State private var flipAngle: Double = 0
    @State private var hintPulse = false

    var body: some View {
        ZStack {
            base
                .rotation3DEffect(.degrees(flipAngle >= 90 ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: width, height: height)
        .scaleEffect(isDragging ? 1.08 : (isHinted && hintPulse ? 1.06 : 1.0))
        .shadow(color: .black.opacity(isDragging ? 0.45 : 0), radius: isDragging ? 10 : 0, x: 0, y: isDragging ? 6 : 0)
        .rotation3DEffect(.degrees(flipAngle), axis: (x: 0, y: 1, z: 0))
        .onAppear { flipAngle = card.isFaceUp ? 180 : 0 }
        .onChange(of: card.isFaceUp) { _, newValue in
            withAnimation(.easeInOut(duration: 0.35)) { flipAngle = newValue ? 180 : 0 }
        }
        .onChange(of: isHinted) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) { hintPulse = true }
            } else {
                hintPulse = false
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isDragging)
    }

    @ViewBuilder
    private var base: some View {
        if flipAngle >= 90 {
            faceContent
        } else {
            backContent
        }
    }

    private var faceContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.cream)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(isHinted ? Theme.scorched : Color.black.opacity(0.25), lineWidth: isHinted ? 3 : 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)

            GeometryReader { geo in
                let color = card.suit.isRed ? Theme.ember : Theme.ink
                ZStack {
                    pipLayout(for: card.rank, size: geo.size, color: color)

                    VStack {
                        HStack {
                            corner(color: color)
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            corner(color: color)
                                .rotationEffect(.degrees(180))
                        }
                    }
                    .padding(geo.size.width * 0.08)
                }
            }
            .padding(6)
        }
    }

    private func corner(color: Color) -> some View {
        VStack(spacing: 0) {
            Text(card.rank.label)
                .font(.system(size: width * 0.20, weight: .bold, design: .rounded))
            Image(systemName: suitSymbolName)
                .font(.system(size: width * 0.14))
        }
        .foregroundStyle(color)
    }

    private var suitSymbolName: String {
        switch card.suit {
        case .hearts: return "suit.heart.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs: return "suit.club.fill"
        case .spades: return "suit.spade.fill"
        }
    }

    @ViewBuilder
    private func pipLayout(for rank: Rank, size: CGSize, color: Color) -> some View {
        switch rank {
        case .ace:
            Image(systemName: suitSymbolName)
                .font(.system(size: size.width * 0.42))
                .foregroundStyle(color)
        case .jack, .queen, .king:
            faceCardEmblem(color: color, size: size)
        default:
            // At the small card sizes a 7-column tableau needs, a full pip grid
            // (2-10 symbols) collides with the corner indices and reads as clutter.
            // A single centered glyph — the corner already shows the count — stays legible.
            Image(systemName: suitSymbolName)
                .font(.system(size: size.width * 0.34))
                .foregroundStyle(color.opacity(0.85))
        }
    }

    private func faceCardEmblem(color: Color, size: CGSize) -> some View {
        // Small cards leave no room for a crown + letter + suit stacked on top of
        // each other without the pieces crowding into one another — just the big
        // letter reads cleanly at any size, and the corner index already shows the suit.
        Text(card.rank.label)
            .font(.system(size: size.width * 0.46, weight: .heavy, design: .serif))
            .foregroundStyle(color)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(color.opacity(0.3), lineWidth: 1.5)
                    .padding(size.width * 0.16)
            )
    }

    private var backContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Theme.accentGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)

            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(Theme.cream.opacity(0.55), lineWidth: 1.5)
                .padding(6)

            CardBackPattern()
                .stroke(Theme.cream.opacity(0.25), lineWidth: 1)
                .padding(10)
                .clipShape(RoundedRectangle(cornerRadius: 5))

            Image(systemName: "suit.spade.fill")
                .font(.system(size: width * 0.24))
                .foregroundStyle(Theme.cream.opacity(0.5))
        }
    }
}

/// A simple diamond lattice drawn with straight lines, used as the card-back decoration.
private struct CardBackPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / 3
        var x = rect.minX - rect.height
        while x < rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.maxY))
            path.move(to: CGPoint(x: x + rect.height, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }
        return path
    }
}
