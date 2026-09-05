import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appSettings: AppSettingsStore
    @State private var showMenu = false
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var creditsOpacity: Double = 0

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        ZStack {
            if showMenu {
                MenuView()
                    .transition(.opacity.combined(with: .scale(scale: 1.03)))
            } else {
                splash
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showMenu)
    }

    private var splash: some View {
        ZStack {
            Theme.gradient.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 10) {
                    Image(systemName: "suit.spade.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.accentGradient)
                    Text(L10n.t(.appName, lang))
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.cream)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Spacer()

                VStack(spacing: 6) {
                    Text(L10n.t(.developedBy, lang))
                        .font(.footnote.weight(.semibold))
                    Link("ividi.dev", destination: URL(string: "https://ividi.dev/")!)
                        .font(.footnote)
                    Link("github.com/VidiPT89", destination: URL(string: "https://github.com/VidiPT89/")!)
                        .font(.footnote)
                }
                .foregroundStyle(Theme.cream.opacity(0.85))
                .tint(Theme.scorched)
                .opacity(creditsOpacity)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                logoScale = 1
                logoOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
                creditsOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { showMenu = true }
            }
        }
    }
}
