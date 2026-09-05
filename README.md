# 🃏 iSolitaire

> Classic Klondike Solitaire, natively reimagined for iOS with SwiftUI.

[Report Bug](https://github.com/VidiPT89/iSolitaire/issues) · [Request Feature](https://github.com/VidiPT89/iSolitaire/issues)

## ✨ Features

- ✅ Classic Klondike rules — draw 1 or draw 3, unlimited or limited stock recycles
- ✅ Smooth drag & drop with valid-move highlighting and animated snap-back
- ✅ Double-tap to auto-send a card to the right foundation
- ✅ Unlimited undo, hint system, and one-tap auto-complete when the board is solved
- ✅ Classic scoring, timer, move counter and a cascading win animation
- ✅ Local statistics: games played/won, win rate, best time, win streaks, best score
- ✅ Animated splash screen with developer credits
- ✅ PT-PT / English language switch
- ✅ Light, Dark and System appearance modes
- ✅ Universal app — iPhone and iPad, portrait and landscape

## 🛠️ Tech Stack

| Category   | Technology          |
|------------|----------------------|
| Language   | Swift                |
| UI         | SwiftUI              |
| State      | Combine / ObservableObject |
| Persistence| UserDefaults (Codable) |
| IDE        | Xcode                |

## 🚀 Quick Start

### Prerequisites
- Xcode 16+
- iOS 17+ simulator or device

### Installation
```bash
git clone https://github.com/VidiPT89/iSolitaire.git
cd iSolitaire
open iSolitaire.xcodeproj
```

Build and run on any iPhone or iPad simulator/device.

## 📖 Usage

- Tap the stock pile to draw cards into the waste pile.
- Drag cards between the tableau, waste and foundations, or double-tap a card to auto-move it to its foundation.
- Use the toolbar to undo, request a hint, auto-complete a solved board, or start a new game.
- Open Settings to change language, appearance, draw mode and recycle limits.

## 🧪 Testing

Core game rules (move validation, scoring, win detection) live in `GameModel`, isolated from the UI layer for easy unit testing in Xcode's test navigator.

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

## 👨‍💻 Author

**David Arsénio Martins**
🌐 Website: [ividi.dev](https://ividi.dev)
🐙 GitHub: [@VidiPT89](https://github.com/VidiPT89)

## 🤝 Contributing

Contributions, issues and feature requests are welcome. Feel free to check the [issues page](https://github.com/VidiPT89/iSolitaire/issues).

---

<p align="center">Developed by <a href="https://ividi.dev">David Arsénio Martins</a></p>
<p align="center">⭐ Star this repo if you like it!</p>
