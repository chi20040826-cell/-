import Foundation

struct PomodoroSnapshot {
    enum Phase { case focus, shortBreak, longBreak }
    let phase: Phase
    let phaseStart: Date
    let phaseEnd: Date
    let completedPomodoros: Int

    var phaseTitle: String {
        switch phase {
        case .focus: return "集中"
        case .shortBreak: return "休憩"
        case .longBreak: return "長休憩"
        }
    }

    var isFocus: Bool { phase == .focus }
}

struct PomodoroSchedule {
    let focus: TimeInterval
    let shortBreak: TimeInterval
    let longBreak: TimeInterval
    let longBreakEvery: Int

    func snapshot(startedAt: Date, now: Date = Date()) -> PomodoroSnapshot {
        if now <= startedAt {
            return PomodoroSnapshot(phase: .focus, phaseStart: startedAt, phaseEnd: startedAt.addingTimeInterval(focus), completedPomodoros: 0)
        }

        var cursor = startedAt
        var completed = 0
        var nextLongAt = max(1, longBreakEvery)

        // Derive state from absolute time. This survives app kills and date changes.
        while true {
            let focusEnd = cursor.addingTimeInterval(focus)
            if now < focusEnd {
                return PomodoroSnapshot(phase: .focus, phaseStart: cursor, phaseEnd: focusEnd, completedPomodoros: completed)
            }

            completed += 1
            cursor = focusEnd

            let isLong = completed == nextLongAt
            let breakDuration = isLong ? longBreak : shortBreak
            let breakEnd = cursor.addingTimeInterval(breakDuration)
            if now < breakEnd {
                return PomodoroSnapshot(phase: isLong ? .longBreak : .shortBreak,
                                        phaseStart: cursor,
                                        phaseEnd: breakEnd,
                                        completedPomodoros: completed)
            }
            cursor = breakEnd
            if isLong { nextLongAt += max(1, longBreakEvery) }

            // Guard against pathological settings while still supporting very long sessions.
            if completed > 100_000 { return PomodoroSnapshot(phase: .focus, phaseStart: cursor, phaseEnd: cursor.addingTimeInterval(focus), completedPomodoros: completed) }
        }
    }
}
