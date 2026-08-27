import ActivityKit
import WidgetKit
import SwiftUI

struct PomoLoopLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.phaseTitle).font(.headline)
                    Text("🍅 \(context.state.completedPomodoros)").font(.subheadline)
                }
                Spacer()
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .font(.title2.bold())
                    .monospacedDigit()
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.85))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.state.phaseTitle).font(.headline)
                        Text("🍅 \(context.state.completedPomodoros)")
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                        .font(.title3.bold())
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("STOPするまでサイクル継続")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Text("🍅\(context.state.completedPomodoros)")
                    .font(.caption2.bold())
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .monospacedDigit()
                    .frame(maxWidth: 52)
            } minimal: {
                Text("🍅")
            }
        }
    }
}
