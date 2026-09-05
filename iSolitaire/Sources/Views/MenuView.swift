import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appSettings: AppSettingsStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showSettings = false
    @State private var showStats = false
    @State private var hasResumableGame = false
    @State private var standaloneSettings = GameStateStore.loadSettings() ?? GameSettings()

    private var lang: AppLanguage { appSettings.language }
    private var textColor: Color { Theme.primaryText(for: colorScheme) }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.tableFelt(for: colorScheme).ignoresSafeArea()

                VStack(spacing: 22) {
                    Spacer()

                    VStack(spacing: 8) {
                        Image(systemName: "suit.spade.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Theme.accentGradient)
                        Text(L10n.t(.appName, lang))
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(textColor)
                    }

                    Spacer()

                    VStack(spacing: 14) {
                        if hasResumableGame {
                            NavigationLink(value: Route.board(startFresh: false)) {
                                menuButton(L10n.t(.continueGame, lang), icon: "play.fill", primary: true)
                            }
                        }
                        NavigationLink(value: Route.board(startFresh: true)) {
                            menuButton(L10n.t(.newGame, lang), icon: "arrow.clockwise", primary: !hasResumableGame)
                        }
                        Button {
                            showStats = true
                        } label: {
                            menuButton(L10n.t(.stats, lang), icon: "chart.bar.fill", primary: false)
                        }
                        Button {
                            showSettings = true
                        } label: {
                            menuButton(L10n.t(.settings, lang), icon: "gearshape.fill", primary: false)
                        }
                    }
                    .padding(.horizontal, 32)

                    Spacer()

                    VStack(spacing: 4) {
                        Text(L10n.t(.developedBy, lang)).font(.caption.weight(.semibold))
                        HStack(spacing: 12) {
                            Link("ividi.dev", destination: URL(string: "https://ividi.dev/")!)
                            Link("github.com/VidiPT89", destination: URL(string: "https://github.com/VidiPT89/")!)
                        }
                        .font(.caption2)
                    }
                    .foregroundStyle(textColor.opacity(0.7))
                    .tint(Theme.ember)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .board(let startFresh):
                    BoardView(startFresh: startFresh)
                }
            }
            .onAppear {
                hasResumableGame = GameStateStore.loadState().map { !$0.isWon } ?? false
                standaloneSettings = GameStateStore.loadSettings() ?? GameSettings()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(gameSettings: $standaloneSettings).environmentObject(appSettings)
            }
            .sheet(isPresented: $showStats) {
                StatsView().environmentObject(appSettings)
            }
            .onChange(of: standaloneSettings) { _, newValue in
                GameStateStore.saveSettings(newValue)
            }
        }
    }

    private func menuButton(_ title: String, icon: String, primary: Bool) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title).font(.headline)
            Spacer()
        }
        .padding()
        .foregroundStyle(primary ? .white : textColor)
        .background(
            primary ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Color.primary.opacity(0.08)),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
}

private enum Route: Hashable {
    case board(startFresh: Bool)
}
