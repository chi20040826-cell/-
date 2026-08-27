import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class PomodoroModel: ObservableObject {
    @Published var isRunning = false
    @Published var snapshot: PomodoroSnapshot?
    @Published var liveActivityStatus = "Live Activity状態を確認中…"

    @AppStorage("focusMinutes") var focusMinutes = 25
    @AppStorage("shortBreakMinutes") var shortBreakMinutes = 5
    @AppStorage("longBreakMinutes") var longBreakMinutes = 15
    @AppStorage("longBreakEvery") var longBreakEvery = 4
    @AppStorage("sessionStart") private var sessionStartEpoch: Double = 0

    private let live = LiveActivityManager()
    private var timer: Timer?

    init() {
        isRunning = sessionStartEpoch > 0
        refresh()
        startTicker()
        Task {
            await requestNotifications()
            liveActivityStatus = live.authorizationSummary()
        }
    }

    var schedule: PomodoroSchedule {
        PomodoroSchedule(
            focus: TimeInterval(max(1, focusMinutes) * 60),
            shortBreak: TimeInterval(max(1, shortBreakMinutes) * 60),
            longBreak: TimeInterval(max(1, longBreakMinutes) * 60),
            longBreakEvery: max(1, longBreakEvery)
        )
    }

    var sessionStart: Date? {
        sessionStartEpoch > 0 ? Date(timeIntervalSince1970: sessionStartEpoch) : nil
    }

    func start() {
        let now = Date()
        sessionStartEpoch = now.timeIntervalSince1970
        isRunning = true
        refresh()
        liveActivityStatus = "⏳ Live Activity開始要求中…"
        Task {
            if let snapshot {
                liveActivityStatus = await live.start(sessionStart: now, snapshot: snapshot)
            }
            await scheduleUpcomingNotifications()
        }
    }

    func retryLiveActivity() {
        guard let start = sessionStart, let snapshot else {
            liveActivityStatus = live.authorizationSummary()
            return
        }
        liveActivityStatus = "⏳ Live Activity再試行中…"
        Task {
            liveActivityStatus = await live.start(sessionStart: start, snapshot: snapshot)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        sessionStartEpoch = 0
        isRunning = false
        snapshot = nil
        liveActivityStatus = "停止済み / " + live.authorizationSummary()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        Task { await live.end() }
        startTicker()
    }

    func refresh() {
        guard let start = sessionStart else {
            isRunning = false
            snapshot = nil
            return
        }
        isRunning = true
        let newSnapshot = schedule.snapshot(startedAt: start)
        let changedPhase = snapshot?.phaseEnd != newSnapshot.phaseEnd
        snapshot = newSnapshot
        if changedPhase {
            Task {
                let result = await live.update(snapshot: newSnapshot)
                // Do not overwrite a useful start error with a harmless "0件" during initial startup.
                if !result.contains("0件") {
                    liveActivityStatus = result
                }
                await scheduleUpcomingNotifications()
            }
        }
    }

    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    private func requestNotifications() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    private func scheduleUpcomingNotifications() async {
        guard let start = sessionStart else { return }
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        var probe = Date()
        for index in 0..<40 {
            let snap = schedule.snapshot(startedAt: start, now: probe)
            let next = snap.phaseEnd
            guard next > Date() else { probe = next.addingTimeInterval(0.5); continue }
            let content = UNMutableNotificationContent()
            content.sound = .default
            content.title = snap.isFocus ? "集中終了" : "休憩終了"
            content.body = snap.isFocus ? "次の休憩へ自動で進みます" : "次の集中へ自動で進みます"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, next.timeIntervalSinceNow), repeats: false)
            let req = UNNotificationRequest(identifier: "pomoloop-\(index)", content: content, trigger: trigger)
            try? await center.add(req)
            probe = next.addingTimeInterval(0.5)
        }
    }
}
