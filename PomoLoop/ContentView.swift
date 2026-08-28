import SwiftUI

struct ContentView: View {
    @StateObject private var model = PomodoroModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Text(model.snapshot?.phaseTitle ?? "準備完了")
                        .font(.title2.bold())

                    if let snapshot = model.snapshot {
                        Text(timerInterval: Date()...snapshot.phaseEnd, countsDown: true)
                            .font(.system(size: 62, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())

                        Text("🍅 \(snapshot.completedPomodoros)")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))

                        Text("STARTからSTOPまでの完了ポモドーロ数")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(format: "%02d:00", model.focusMinutes))
                            .font(.system(size: 62, weight: .bold, design: .rounded))
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

                    VStack(alignment: .leading, spacing: 14) {
                        Text("サイクル設定")
                            .font(.headline)

                        Stepper("集中  \(model.focusMinutes)分", value: $model.focusMinutes, in: 1...180)
                        Divider()
                        Stepper("短休憩  \(model.shortBreakMinutes)分", value: $model.shortBreakMinutes, in: 1...60)
                        Divider()
                        Stepper("長休憩  \(model.longBreakMinutes)分", value: $model.longBreakMinutes, in: 1...120)
                        Divider()
                        Stepper("長休憩は \(model.longBreakEvery)🍅 ごと", value: $model.longBreakEvery, in: 1...20)

                        if model.isRunning {
                            Text("設定変更は次にSTARTしたセッションから使うのがおすすめです")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 10) {
                        Button("🔔 通知音をテスト") {
                            model.testNotificationSound()
                        }
                        .buttonStyle(.bordered)

                        if !model.notificationStatus.isEmpty {
                            Text(model.notificationStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("集中・休憩の終了時は標準通知音＋通知で知らせます")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .navigationTitle("PomoLoop")
        }
    }
}
