import SwiftUI

struct StatsView: View {
    @EnvironmentObject var appSettings: AppSettingsStore
    @Environment(\.dismiss) private var dismiss
    private let stats = StatsStore().load()

    private var lang: AppLanguage { appSettings.language }

    private var winRate: Int {
        stats.gamesPlayed == 0 ? 0 : Int((Double(stats.gamesWon) / Double(stats.gamesPlayed)) * 100)
    }

    var body: some View {
        NavigationStack {
            List {
                row(L10n.t(.gamesPlayed, lang), "\(stats.gamesPlayed)")
                row(L10n.t(.gamesWon, lang), "\(stats.gamesWon)")
                row(L10n.t(.winRate, lang), "\(winRate)%")
                row(L10n.t(.bestTime, lang), stats.bestTimeSeconds.map { "\($0 / 60):\(String(format: "%02d", $0 % 60))" } ?? "—")
                row(L10n.t(.winStreak, lang), "\(stats.currentWinStreak)")
                row(L10n.t(.bestStreak, lang), "\(stats.bestWinStreak)")
                row(L10n.t(.bestScore, lang), "\(stats.bestScore)")
            }
            .navigationTitle(L10n.t(.stats, lang))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t(.close, lang)) { dismiss() }
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).bold().foregroundStyle(Theme.ember)
        }
    }
}
