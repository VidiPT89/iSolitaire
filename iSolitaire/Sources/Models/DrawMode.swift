import Foundation

enum DrawMode: String, CaseIterable, Codable {
    case drawOne
    case drawThree
}

enum RecycleMode: String, CaseIterable, Codable {
    case unlimited
    case limited
}

struct GameSettings: Codable, Equatable {
    var drawMode: DrawMode = .drawOne
    var recycleMode: RecycleMode = .unlimited
    var recycleLimit: Int = 3
}
