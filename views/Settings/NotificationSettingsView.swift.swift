import SwiftUI
import AVFoundation

struct NotificationSettingsView: View {
    @State private var drowsyAlert = true
    @State private var badMoodAlert = false
    @State private var goodMoodAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("졸음 감지 알림")) {
                    Toggle("알림 사용", isOn: $drowsyAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "drowsy_alert")
                    }
                }

                Section(header: Text("기분 안 좋을 때 알림")) {
                    Toggle("알림 사용", isOn: $badMoodAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "bad_mood_alert")
                    }
                }

                Section(header: Text("기분 좋을 때 알림")) {
                    Toggle("알림 사용", isOn: $goodMoodAlert)
                    Button("사운드 재생") {
                        SoundPlayer.shared.play(fileName: "good_mood_alert")
                    }
                }
            }
            .navigationTitle("알림 설정")
        }
    }
}

class SoundPlayer {
    static let shared = SoundPlayer()
    private var player: AVAudioPlayer?

    func play(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("❌ 사운드 파일을 찾을 수 없음: \(fileName)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ 오디오 재생 실패: \(error.localizedDescription)")
        }
    }
}
