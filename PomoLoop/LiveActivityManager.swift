import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    private var activity: Activity<PomodoroActivityAttributes>?

    func start(sessionStart: Date, snapshot: PomodoroSnapshot) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = PomodoroActivityAttributes(sessionStartedAt: sessionStart)
        let state = PomodoroActivityAttributes.ContentState(
            phaseTitle: snapshot.phaseTitle,
            phaseEnd: snapshot.phaseEnd,
            completedPomodoros: snapshot.completedPomodoros,
            isFocus: snapshot.isFocus
        )
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: snapshot.phaseEnd),
                pushType: nil
            )
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }

    func update(snapshot: PomodoroSnapshot) async {
        let state = PomodoroActivityAttributes.ContentState(
            phaseTitle: snapshot.phaseTitle,
            phaseEnd: snapshot.phaseEnd,
            completedPomodoros: snapshot.completedPomodoros,
            isFocus: snapshot.isFocus
        )
        for item in Activity<PomodoroActivityAttributes>.activities {
            await item.update(ActivityContent(state: state, staleDate: snapshot.phaseEnd))
        }
    }

    func end() async {
        for item in Activity<PomodoroActivityAttributes>.activities {
            await item.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
