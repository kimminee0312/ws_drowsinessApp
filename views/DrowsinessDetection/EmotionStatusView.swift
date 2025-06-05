import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct EmotionStatusView: View {
    @State private var emotionStatus: String = "System requesting..."
    @State private var hasReceivedStatus = false
    @State private var showFailureAlert = false
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    // 토글 상태를 AppStorage로 유지
    @AppStorage("badMoodAlert") private var badMoodAlert = false
    @AppStorage("goodMoodAlert") private var goodMoodAlert = false
    
    @State private var previousStatus: String = ""
    @State private var listener: ListenerRegistration? // 추가
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Emotion Detector System")
                .font(.title2)
                .bold()
                .padding(.top)
            
            if showFailureAlert {
                Text("Emotion Detector System Failed.")
                    .foregroundColor(.red)
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
            } else {
                Text(emotionStatus)
                    .font(.title3)
                    // 포함되는 단어 들어오면 글씨 빨간색으로 변함
                    .foregroundColor(emotionStatus.contains("negative") ? .red : (emotionStatus.contains("positive") ? .green : .gray))
                    .bold()
            }
            
            Spacer()
            
            Button(action: stopButtonAction){
                Text("Stop System")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear(perform: listenToStatus)
        .onDisappear { removeListener()}
        .background(Color.white.ignoresSafeArea())
    }
    
    private func stopButtonAction() {
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            sendEndEmotionRequest(uid: uid) { success in
                if success {
                    removeListener()
                    DispatchQueue.main.async {
                        dismiss()
                    }
                } else {
                    print("❗️종료 요청 실패")
                }
            }
        }
    }

    private func removeListener() {
        listener?.remove()
        listener = nil
        print("🔥 리스너 제거됨")
    }
    
    func listenToStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docRef = Firestore.firestore().collection("users").document(uid)
        

        listener = docRef.addSnapshotListener { snapshot, error in
            guard listener != nil else { return }  // Listener 종료 후 추가 이벤트 무시
            
            
            if let data = snapshot?.data(), let alertStatus = data["emotion status"] as? String {
                emotionStatus = alertStatus
                hasReceivedStatus = true
                
                // 조건에 따라 음성 재생
                handleEmotionStatus(alertStatus)
            }
        }
        //20초 안에 status가 안 오면 실패 간주
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !hasReceivedStatus {
                showFailureAlert = true
            }
        }
    }
    // 알림 상태에 따른 음성 재생 처리 함수 추가
    private func handleEmotionStatus(_ status: String) {
        DispatchQueue.main.async {
            guard status != previousStatus else { return }

            if status.contains("negative") && badMoodAlert {
                SoundPlayer.shared.play(fileName: "negative_message")
            } else if status.contains("positive") && goodMoodAlert {
                SoundPlayer.shared.play(fileName: "positive_alert")
            }

            previousStatus = status
        }
    }
    
    func sendEndEmotionRequest(uid: String, completion: @escaping (Bool) -> Void) {
        let baseURL = AppConfig.shared.serverBaseURL
        guard let url = URL(string: "\(baseURL)/end_emotion") else {
            completion(false)
            return
        }
        let payload = ["uid": uid]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ end_emotion 요청 완료")
                completion(true)
            } else {
                print("❌ end_emotion 요청 실패:", error?.localizedDescription ?? "unknown")
                completion(false)
            }
        }.resume()
    }
    
}
