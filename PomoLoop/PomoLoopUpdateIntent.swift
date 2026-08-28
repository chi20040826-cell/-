import AppIntents
import ActivityKit
import Foundation

struct PomoLoopUpdateIntent: AppIntent {
    static var title: LocalizedStringResource = "PomoLoop Update"
    static var description = IntentDescription("現在時刻からPomoLoopのフェーズを再計算し、Live Activityを同期します。")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults.standard
        let startEpoch = defaults.double(forKey: "sessionStart")
        guard startEpoch > 0 else {
            return .result(dialog: "PomoLoopは停止中です")
        }

        let focusMinutes = max(1, defaults.integer(forKey: "focusMinutes"))
        let shortBreakMinutes = max(1, defaults.integer(forKey: "shortBreakMinutes"))
        let longBreakMinutes = max(1, defaults.integer(forKey: "longBreakMinutes"))
        let storedEvery = defaults.integer(forKey: "longBreakEvery")
        let longBreakEvery = max(1, storedEvery == 0 ? 4 : storedEvery)

        let schedule = PomodoroSchedule(
            focus: TimeInterval(focusMinutes * 60),
            shortBreak: TimeInterval(shortBreakMinutes * 60),
            longBreak: TimeInterval(longBreakMinutes * 60),
            longBreakEvery: longBreakEvery
        )
        let snapshot = schedule.snapshot(
            startedAt: Date(timeIntervalSince1970: startEpoch),
            now: Date()
        )

        let state = PomodoroActivityAttributes.ContentState(
            phaseTitle: snapshot.phaseTitle,
            phaseEnd: snapshot.phaseEnd,
            completedPomodoros: snapshot.completedPomodoros,
            isFocus: snapshot.isFocus
        )

        let activities = Activity<PomodoroActivityAttributes>.activities
        for activity in activities {
            await activity.update(ActivityContent(state: state, staleDate: snapshot.phaseEnd))
        }

        return .result(dialog: "Dynamic Islandを同期しました")
    }
}

struct PomoLoopShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PomoLoopUpdateIntent(),
            phrases: ["PomoLoopを更新", "PomoLoopを同期"],
            shortTitle: "PomoLoop Update",
            systemImageName: "timer"
        )
    }
}
