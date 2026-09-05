import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Codable {
    case portuguese = "pt"
    case english = "en"

    var displayName: String {
        switch self {
        case .portuguese: return "Português"
        case .english: return "English"
        }
    }

    static func systemDefault() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("pt") ? .portuguese : .english
    }
}

enum AppColorScheme: String, CaseIterable, Codable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class AppSettingsStore: ObservableObject {
    @AppStorage("iSolitaire.language") var languageRaw: String = AppLanguage.systemDefault().rawValue
    @AppStorage("iSolitaire.colorScheme") var colorSchemeRaw: String = AppColorScheme.system.rawValue

    var language: AppLanguage {
        get { AppLanguage(rawValue: languageRaw) ?? .english }
        set { languageRaw = newValue.rawValue }
    }

    var colorScheme: AppColorScheme {
        get { AppColorScheme(rawValue: colorSchemeRaw) ?? .system }
        set { colorSchemeRaw = newValue.rawValue }
    }
}
