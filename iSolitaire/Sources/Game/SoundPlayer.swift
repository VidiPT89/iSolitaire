import Foundation
import AVFoundation

/// Plays the app's short synthesized sound effects (card flip, card place, win fanfare).
final class SoundPlayer {
    private var players: [String: AVAudioPlayer] = [:]

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        for name in ["card_flip", "card_place", "win"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.prepareToPlay()
            players[name] = player
        }
    }

    func cardFlip() { play("card_flip") }
    func cardPlace() { play("card_place") }
    func win() { play("win") }

    private func play(_ name: String) {
        guard let player = players[name] else { return }
        if player.isPlaying { player.currentTime = 0 } else { player.play() }
        if !player.isPlaying { player.play() }
    }
}
