import SwiftUI

struct BoardView: View {
    @StateObject private var game = GameModel()
    @EnvironmentObject var appSettings: AppSettingsStore
    @State private var showSettings = false
    @State private var showStats = false
    @State private var showWin = false

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        ZStack {
            Theme.tableFelt(for: .dark).ignoresSafeArea()

            VStack(spacing: 16) {
                header

                HStack(alignment: .top, spacing: 14) {
                    StockView(game: game)
                    WasteView(game: game)
                    Spacer(minLength: 8)
                    ForEach(Suit.allCases, id: \.self) { suit in
                        FoundationView(game: game, suit: suit)
                    }
                }
                .padding(.horizontal)

                HStack(alignment: .top, spacing: 10) {
                    ForEach(0..<7, id: \.self) { column in
                        TableauColumnView(game: game, column: column)
                    }
                }
                .padding(.horizontal, 8)

                Spacer()

                toolbar
            }
            .padding(.top)
        }
        .onChange(of: game.wonAnimationTrigger) { _, newValue in
            if newValue > 0 { showWin = true }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(game: game).environmentObject(appSettings)
        }
        .sheet(isPresented: $showStats) {
            StatsView().environmentObject(appSettings)
        }
        .overlay {
            if showWin {
                WinOverlay(game: game, showWin: $showWin).environmentObject(appSettings)
            }
        }
    }

    private var header: some View {
        HStack {
            statPill(L10n.t(.score, lang), "\(game.state.score)")
            statPill(L10n.t(.moves, lang), "\(game.state.moves)")
            statPill(L10n.t(.time, lang), timeString(game.state.elapsedSeconds))
            Spacer()
            Button { showStats = true } label: {
                Image(systemName: "chart.bar.fill")
            }
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
            }
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Theme.cream)
        .padding(.horizontal)
    }

    private var toolbar: some View {
        HStack(spacing: 20) {
            toolbarButton(icon: "arrow.uturn.backward", title: L10n.t(.undo, lang), disabled: !game.canUndo) {
                withAnimation { game.undo() }
            }
            toolbarButton(icon: "lightbulb.fill", title: L10n.t(.hint, lang)) {
                withAnimation { game.requestHint() }
            }
            toolbarButton(icon: "wand.and.stars", title: L10n.t(.autoComplete, lang), disabled: !game.lastAutoCompleteAvailable) {
                withAnimation { game.autoComplete() }
            }
            toolbarButton(icon: "arrow.clockwise", title: L10n.t(.newGame, lang)) {
                withAnimation { game.newGame() }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func statPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.subheadline.bold())
            Text(label).font(.caption2).opacity(0.7)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.accentGradient.opacity(0.18), in: RoundedRectangle(cornerRadius: 10))
    }

    private func toolbarButton(icon: String, title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.caption2)
            }
            .foregroundStyle(disabled ? Theme.cream.opacity(0.3) : Theme.cream)
        }
        .disabled(disabled)
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
