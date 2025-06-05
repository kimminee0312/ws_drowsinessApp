import SwiftUI
import AVFoundation

struct NotificationSettingsView: View {
    @AppStorage("drowsyAlert") private var drowsyAlert = true
    @AppStorage("yawnAlert") private var yawnAlert = true
    @AppStorage("badMoodAlert") private var badMoodAlert = false
    @AppStorage("goodMoodAlert") private var goodMoodAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("졸음 감지 알림")) {
                    Toggle("알림 사용", isOn: $drowsyAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "drowsy_alert")
                    }
                }
                Section(header: Text("하품 감지 알림")) {
                    Toggle("알림 사용", isOn: $yawnAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "alert1")
                    }
                }
                Section(header: Text("기분 안 좋을 때 알림")) {
                    Toggle("알림 사용", isOn: $badMoodAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "negative_message")
                    }
                }

                Section(header: Text("기분 좋을 때 알림")) {
                    Toggle("알림 사용", isOn: $goodMoodAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "positive_alert")
                    }
                }
            }
            .navigationTitle("알림 설정")
        }
    }
}
