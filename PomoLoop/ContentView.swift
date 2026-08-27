import SwiftUI

struct ContentView: View {
    @StateObject private var model = PomodoroModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 26) {
                Spacer(minLength: 20)
                Text(model.snapshot?.phaseTitle ?? "準備完了")
                    .font(.title2.bold())

                if let snapshot = model.snapshot {
                    Text(timerInterval: Date()...snapshot.phaseEnd, countsDown: true)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    Text("🍅 \(snapshot.completedPomodoros)")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))

                    Text("STARTからSTOPまでの完了ポモドーロ数")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(String(format: "%02d:00", model.focusMinutes))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("日付をまたいでもカウントはリセットされません")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Button(model.isRunning ? "STOP" : "START") {
                    model.isRunning ? model.stop() : model.start()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(model.isRunning ? .red : .accentColor)

                Form {
                    Section("サイクル設定") {
                        Stepper("集中 \(model.focusMinutes)分", value: $model.focusMinutes, in: 1...180)
                        Stepper("短休憩 \(model.shortBreakMinutes)分", value: $model.shortBreakMinutes, in: 1...60)
                        Stepper("長休憩 \(model.longBreakMinutes)分", value: $model.longBreakMinutes, in: 1...120)
                        Stepper("長休憩は \(model.longBreakEvery)🍅 ごと", value: $model.longBreakEvery, in: 1...20)
                    }
                }
                .frame(maxHeight: 260)
            }
            .padding(.horizontal)
            .navigationTitle("PomoLoop")
        }
    }
}
