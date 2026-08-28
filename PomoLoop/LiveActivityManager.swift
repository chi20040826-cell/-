import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    private var activity: Activity<PomodoroActivityAttributes>?

    func authorizationSummary() -> String {
        let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
        let count = Activity<PomodoroActivityAttributes>.activities.count
        return "Live Activities: \(enabled ? "許可" : "無効") / Activity数: \(count)"
    }

    func start(sessionStart: Date, snapshot: PomodoroSnapshot) async -> String {
        let authorization = ActivityAuthorizationInfo()
        guard authorization.areActivitiesEnabled else {
            return "❌ Live Activitiesが無効です。設定 → PomoLoop → Live Activities を確認してください。"
        }

        // Avoid leaving an older debug/session activity around.
        for old in Activity<PomodoroActivityAttributes>.activities {
            await old.end(nil, dismissalPolicy: .immediate)
        }

        let attributes = PomodoroActivityAttributes(sessionStartedAt: sessionStart)
        let state = PomodoroActivityAttributes.ContentState(
            phaseTitle: snapshot.phaseTitle,
            phaseEnd: snapshot.phaseEnd,
            completedPomodoros: snapshot.completedPomodoros,
            isFocus: snapshot.isFocus
        )

        do {
            let newActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: snapshot.phaseEnd),
                pushType: nil
            )
            activity = newActivity
            let count = Activity<PomodoroActivityAttributes>.activities.count
            return "✅ Live Activity開始成功 / ID: \(newActivity.id.prefix(8))… / Activity数: \(count)"
        } catch {
            let nsError = error as NSError
            return "❌ 開始失敗: \(nsError.domain) (\(nsError.code)) — \(nsError.localizedDescription)"
        }
    }

    func update(snapshot: PomodoroSnapshot) async -> String {
        let state = PomodoroActivityAttributes.ContentState(
            phaseTitle: snapshot.phaseTitle,
            phaseEnd: snapshot.phaseEnd,
            completedPomodoros: snapshot.completedPomodoros,
            isFocus: snapshot.isFocus
        )
        let items = Activity<PomodoroActivityAttributes>.activities
        guard !items.isEmpty else {
            return "⚠️ 更新対象のLive Activityが0件です"
        }
        for item in items {
            await item.update(ActivityContent(state: state, staleDate: snapshot.phaseEnd))
        }
        return "✅ Live Activity更新 / Activity数: \(items.count)"
    }

    func end() async {
        for item in Activity<PomodoroActivityAttributes>.activities {
            await item.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
