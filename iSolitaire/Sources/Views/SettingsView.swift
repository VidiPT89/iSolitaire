import SwiftUI

struct SettingsView: View {
    @Binding var gameSettings: GameSettings
    @EnvironmentObject var appSettings: AppSettingsStore
    @Environment(\.dismiss) private var dismiss

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.t(.language, lang)) {
                    Picker(L10n.t(.language, lang), selection: Binding(
                        get: { appSettings.language },
                        set: { appSettings.language = $0 }
                    )) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(L10n.t(.appearance, lang)) {
                    Picker(L10n.t(.appearance, lang), selection: Binding(
                        get: { appSettings.colorScheme },
                        set: { appSettings.colorScheme = $0 }
                    )) {
                        Text(L10n.t(.systemMode, lang)).tag(AppColorScheme.system)
                        Text(L10n.t(.lightMode, lang)).tag(AppColorScheme.light)
                        Text(L10n.t(.darkMode, lang)).tag(AppColorScheme.dark)
                    }
                    .pickerStyle(.segmented)
                }

                Section(L10n.t(.drawMode, lang)) {
                    Picker(L10n.t(.drawMode, lang), selection: $gameSettings.drawMode) {
                        Text(L10n.t(.drawOne, lang)).tag(DrawMode.drawOne)
                        Text(L10n.t(.drawThree, lang)).tag(DrawMode.drawThree)
                    }
                    .pickerStyle(.segmented)
                }

                Section(L10n.t(.recycles, lang)) {
                    Picker(L10n.t(.recycles, lang), selection: $gameSettings.recycleMode) {
                        Text(L10n.t(.unlimited, lang)).tag(RecycleMode.unlimited)
                        Text(L10n.t(.limited, lang)).tag(RecycleMode.limited)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.t(.developedBy, lang)).font(.footnote.bold())
                        Link(L10n.t(.website, lang), destination: URL(string: "https://ividi.dev/")!)
                            .font(.footnote)
                        Link(L10n.t(.github, lang), destination: URL(string: "https://github.com/VidiPT89/")!)
                            .font(.footnote)
                    }
                    .foregroundStyle(Theme.ember)
                }
            }
            .navigationTitle(L10n.t(.settings, lang))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.t(.close, lang)) { dismiss() }
                }
            }
        }
    }
}
