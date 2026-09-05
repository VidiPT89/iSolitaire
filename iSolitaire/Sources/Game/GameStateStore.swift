import Foundation

/// Persists the in-progress game and settings so the app can resume exactly where the player left off.
enum GameStateStore {
    private static let stateKey = "iSolitaire.savedState"
    private static let settingsKey = "iSolitaire.savedSettings"

    static func loadState() -> GameState? {
        guard let data = UserDefaults.standard.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        return state
    }

    static func saveState(_ state: GameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: stateKey)
    }

    static func clearState() {
        UserDefaults.standard.removeObject(forKey: stateKey)
    }

    static func loadSettings() -> GameSettings? {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else {
            return nil
        }
        return settings
    }

    static func saveSettings(_ settings: GameSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: settingsKey)
    }
}
