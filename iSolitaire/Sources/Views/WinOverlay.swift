import SwiftUI

struct WinOverlay: View {
    @ObservedObject var game: GameModel
    @Binding var showWin: Bool
    @EnvironmentObject var appSettings: AppSettingsStore
    @State private var cascade = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            ForEach(0..<24, id: \.self) { i in
                Image(systemName: "suit.\(["heart", "diamond", "club", "spade"][i % 4]).fill")
                    .foregroundStyle(i % 2 == 0 ? Theme.ember : Theme.scorched)
                    .font(.system(size: 22))
                    .offset(x: cascade ? CGFloat.random(in: -160...160) : 0,
                            y: cascade ? CGFloat.random(in: -300...300) : -40)
                    .opacity(cascade ? 1 : 0)
                    .animation(.easeOut(duration: 0.9).delay(Double(i) * 0.03), value: cascade)
            }

            VStack(spacing: 16) {
                Text(L10n.t(.youWon, appSettings.language))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.accentGradient)

                VStack(spacing: 4) {
                    Text("\(L10n.t(.score, appSettings.language)): \(game.state.score)")
                    Text("\(L10n.t(.time, appSettings.language)): \(game.state.elapsedSeconds / 60):\(String(format: "%02d", game.state.elapsedSeconds % 60))")
                }
                .foregroundStyle(Theme.cream)

                Button {
                    showWin = false
                    game.newGame()
                } label: {
                    Text(L10n.t(.playAgain, appSettings.language))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Theme.accentGradient, in: Capsule())
                }
            }
            .padding(28)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .scaleEffect(cascade ? 1 : 0.8)
            .opacity(cascade ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { cascade = true }
        }
    }
}
