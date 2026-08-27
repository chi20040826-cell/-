import ActivityKit
import Foundation

struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var phaseTitle: String
        var phaseEnd: Date
        var completedPomodoros: Int
        var isFocus: Bool
    }

    var sessionStartedAt: Date
}
