import ActivityKit
import WidgetKit
import SwiftUI

@main
struct PomoLoopLiveActivity: Widget {
    private func phaseColor(_ state: PomodoroActivityAttributes.ContentState) -> Color {
        if state.isFocus { return .red }
        if state.phaseTitle == "長休憩" { return .blue }
        return .green
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            let color = phaseColor(context.state)
            VStack(spacing: 8) {
                Text("PomoLoop")
                    .font(.headline)
                    .foregroundStyle(color)
                Text(context.state.phaseTitle)
                    .foregroundStyle(color)
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .font(.title.bold())
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text("🍅 \(context.state.completedPomodoros)")
                    .foregroundStyle(color)
            }
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(color)
        } dynamicIsland: { context in
            let color = phaseColor(context.state)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🍅 \(context.state.completedPomodoros)")
                        .foregroundStyle(color)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                        .monospacedDigit()
                        .foregroundStyle(color)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.phaseTitle)
                        .foregroundStyle(color)
                }
            } compactLeading: {
                Text("🍅\(context.state.completedPomodoros)")
                    .foregroundStyle(color)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .monospacedDigit()
                    .foregroundStyle(color)
            } minimal: {
                Text("🍅")
                    .foregroundStyle(color)
            }
            .keylineTint(color)
        }
    }
}
