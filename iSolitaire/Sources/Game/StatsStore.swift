import Foundation

struct GameStats: Codable, Equatable {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var bestTimeSeconds: Int?
    var currentWinStreak: Int = 0
    var bestWinStreak: Int = 0
    var bestScore: Int = 0
}

final class StatsStore {
    private let defaultsKey = "iSolitaire.stats"

    func load() -> GameStats {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let stats = try? JSONDecoder().decode(GameStats.self, from: data) else {
            return GameStats()
        }
        return stats
    }

    private func save(_ stats: GameStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    func recordWin(time: Int, score: Int) {
        var stats = load()
        stats.gamesPlayed += 1
        stats.gamesWon += 1
        stats.currentWinStreak += 1
        stats.bestWinStreak = max(stats.bestWinStreak, stats.currentWinStreak)
        stats.bestTimeSeconds = min(stats.bestTimeSeconds ?? Int.max, time)
        stats.bestScore = max(stats.bestScore, score)
        save(stats)
    }

    func recordAbandon() {
        var stats = load()
        stats.gamesPlayed += 1
        stats.currentWinStreak = 0
        save(stats)
    }
}
