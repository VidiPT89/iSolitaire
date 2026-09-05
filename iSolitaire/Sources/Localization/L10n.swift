import Foundation

enum L10nKey: String {
    case appName
    case newGame
    case undo
    case hint
    case autoComplete
    case settings
    case stats
    case score
    case moves
    case time
    case drawMode
    case drawOne
    case drawThree
    case recycles
    case unlimited
    case limited
    case appearance
    case systemMode
    case lightMode
    case darkMode
    case language
    case gamesPlayed
    case gamesWon
    case bestTime
    case winStreak
    case bestStreak
    case bestScore
    case youWon
    case playAgain
    case close
    case developedBy
    case website
    case github
    case winRate
}

enum L10n {
    private static let strings: [AppLanguage: [L10nKey: String]] = [
        .portuguese: [
            .appName: "iSolitaire",
            .newGame: "Novo Jogo",
            .undo: "Anular",
            .hint: "Dica",
            .autoComplete: "Terminar Automaticamente",
            .settings: "Definições",
            .stats: "Estatísticas",
            .score: "Pontuação",
            .moves: "Jogadas",
            .time: "Tempo",
            .drawMode: "Modo de Compra",
            .drawOne: "Virar 1 Carta",
            .drawThree: "Virar 3 Cartas",
            .recycles: "Reciclagens",
            .unlimited: "Ilimitadas",
            .limited: "Limitadas",
            .appearance: "Aparência",
            .systemMode: "Sistema",
            .lightMode: "Claro",
            .darkMode: "Escuro",
            .language: "Idioma",
            .gamesPlayed: "Jogos Jogados",
            .gamesWon: "Jogos Ganhos",
            .bestTime: "Melhor Tempo",
            .winStreak: "Sequência Atual",
            .bestStreak: "Melhor Sequência",
            .bestScore: "Melhor Pontuação",
            .youWon: "Ganhaste!",
            .playAgain: "Jogar Novamente",
            .close: "Fechar",
            .developedBy: "Criado por David Arsénio Martins",
            .website: "ividi.dev",
            .github: "github.com/VidiPT89",
            .winRate: "Taxa de Vitórias",
        ],
        .english: [
            .appName: "iSolitaire",
            .newGame: "New Game",
            .undo: "Undo",
            .hint: "Hint",
            .autoComplete: "Auto-Complete",
            .settings: "Settings",
            .stats: "Statistics",
            .score: "Score",
            .moves: "Moves",
            .time: "Time",
            .drawMode: "Draw Mode",
            .drawOne: "Draw 1 Card",
            .drawThree: "Draw 3 Cards",
            .recycles: "Recycles",
            .unlimited: "Unlimited",
            .limited: "Limited",
            .appearance: "Appearance",
            .systemMode: "System",
            .lightMode: "Light",
            .darkMode: "Dark",
            .language: "Language",
            .gamesPlayed: "Games Played",
            .gamesWon: "Games Won",
            .bestTime: "Best Time",
            .winStreak: "Current Streak",
            .bestStreak: "Best Streak",
            .bestScore: "Best Score",
            .youWon: "You Won!",
            .playAgain: "Play Again",
            .close: "Close",
            .developedBy: "Developed by David Arsénio Martins",
            .website: "ividi.dev",
            .github: "github.com/VidiPT89",
            .winRate: "Win Rate",
        ],
    ]

    static func t(_ key: L10nKey, _ language: AppLanguage) -> String {
        strings[language]?[key] ?? strings[.english]?[key] ?? key.rawValue
    }
}
