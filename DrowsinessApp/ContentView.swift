import SwiftUI
import Firebase
import FirebaseFirestore
import UserNotifications

struct ContentView: View {
    @State private var showStatusView = false
    @State private var drowsyStatus: String = "Loading..."

    var body: some View {
        if showStatusView {
            VStack(spacing: 20) {
                Image(systemName: "eye")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)

                Text("졸음 상태:")
                    .font(.title2)

                Text(drowsyStatus)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.red)
            }
            .padding()
            .onAppear {
                listenToRealtimeStatus()
            }
        } else {
            VStack(spacing: 20) {
                Text("졸음 운전 인식 앱")
                    .font(.largeTitle)
                    .bold()

                Button("시작하기") {
                    showStatusView = true
                }
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    func listenToRealtimeStatus() {
        let db = Firestore.firestore()
        db.collection("users").document("test_user").addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                drowsyStatus = "데이터 없음"
                return
            }
            let state = data["state"] as? String ?? "Unknown"
            drowsyStatus = state

            if state == "Drowsy 😴" {
                print("🟡 졸음 상태 감지됨 → 알림 보내기")
                sendLocalNotification()
            }
        }
    }

    func sendLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ 졸음 감지!"
        content.body = "졸음 상태가 감지되었습니다. 주의를 기울이세요!"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    ContentView()
}
