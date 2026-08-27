import ActivityKit
import WidgetKit
import SwiftUI

@main
struct PomoLoopLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            VStack(spacing: 8) {
                Text("PomoLoop")
                    .font(.headline)
                Text(context.state.phaseTitle)
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .font(.title.bold())
                    .monospacedDigit()
                Text("🍅 \(context.state.completedPomodoros)")
            }
            .foregroundStyle(.white)
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🍅 \(context.state.completedPomodoros)")
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.phaseTitle)
                        .foregroundStyle(.white)
                }
            } compactLeading: {
                Text("🍅\(context.state.completedPomodoros)")
                    .foregroundStyle(.white)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .monospacedDigit()
                    .foregroundStyle(.white)
            } minimal: {
                Text("🍅")
                    .foregroundStyle(.white)
            }
            .keylineTint(.white)
        }
    }
}
