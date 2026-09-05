import SwiftUI

@main
struct iSolitaireApp: App {
    @StateObject private var appSettings = AppSettingsStore()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.colorScheme.colorScheme)
        }
    }
}
