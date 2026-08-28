import Foundation
import BackgroundTasks
import ActivityKit

@MainActor
enum BackgroundRefreshManager {
    static let identifier = "com.pomoloop.private.refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(refreshTask)
        }
    }

    static func scheduleNext() {
        let defaults = UserDefaults.standard
        let startEpoch = defaults.double(forKey: "sessionStart")
        guard startEpoch > 0 else { return }

        let focus = max(1, defaults.integer(forKey: "focusMinutes"))
        let shortBreak = max(1, defaults.integer(forKey: "shortBreakMinutes"))
        let longBreak = max(1, defaults.integer(forKey: "longBreakMinutes"))
        let every = max(1, defaults.integer(forKey: "longBreakEvery"))

        let schedule = PomodoroSchedule(
            focus: TimeInterval(focus * 60),
            shortBreak: TimeInterval(shortBreak * 60),
            longBreak: TimeInterval(longBreak * 60),
            longBreakEvery: every
        )
        let snap = schedule.snapshot(startedAt: Date(timeIntervalSince1970: startEpoch))

        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        // This is a request, not a guarantee. iOS chooses the actual launch time.
        request.earliestBeginDate = snap.phaseEnd.addingTimeInterval(1)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("PomoLoop BG submit failed: \(error)")
        }
    }

    private static func handle(_ task: BGAppRefreshTask) {
        var cancelled = false
        task.expirationHandler = { cancelled = true }

        Task { @MainActor in
            guard !cancelled else {
                task.setTaskCompleted(success: false)
                return
            }

            let defaults = UserDefaults.standard
            let startEpoch = defaults.double(forKey: "sessionStart")
            guard startEpoch > 0 else {
                task.setTaskCompleted(success: true)
                return
            }

            let focus = max(1, defaults.integer(forKey: "focusMinutes"))
            let shortBreak = max(1, defaults.integer(forKey: "shortBreakMinutes"))
            let longBreak = max(1, defaults.integer(forKey: "longBreakMinutes"))
            let every = max(1, defaults.integer(forKey: "longBreakEvery"))
            let schedule = PomodoroSchedule(
                focus: TimeInterval(focus * 60),
                shortBreak: TimeInterval(shortBreak * 60),
                longBreak: TimeInterval(longBreak * 60),
                longBreakEvery: every
            )
            let snap = schedule.snapshot(startedAt: Date(timeIntervalSince1970: startEpoch))
            let state = PomodoroActivityAttributes.ContentState(
                phaseTitle: snap.phaseTitle,
                phaseEnd: snap.phaseEnd,
                completedPomodoros: snap.completedPomodoros,
                isFocus: snap.isFocus
            )

            for activity in Activity<PomodoroActivityAttributes>.activities {
                await activity.update(ActivityContent(state: state, staleDate: snap.phaseEnd))
            }

            scheduleNext()
            task.setTaskCompleted(success: true)
        }
    }
}
