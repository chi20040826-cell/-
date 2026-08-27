import ActivityKit
import WidgetKit
import SwiftUI

struct PomoLoopLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.phaseTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("🍅 \(context.state.completedPomodoros)")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                Spacer()
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.90))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.phaseTitle)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("🍅 \(context.state.completedPomodoros)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                        .font(.title3.bold())
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("STOPするまでサイクル継続")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
            } compactLeading: {
                HStack(spacing: 2) {
                    Text("🍅")
                    Text("\(context.state.completedPomodoros)")
                        .monospacedDigit()
                }
                .font(.caption2.bold())
                .foregroundStyle(.white)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.phaseEnd, countsDown: true)
                    .font(.caption.bold())
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .frame(width: 50)
            } minimal: {
                Text("🍅")
                    .foregroundStyle(.white)
            }
            .keylineTint(.white)
        }
    }
}
