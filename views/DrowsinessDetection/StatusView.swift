import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct StatusView: View {
    @State private var drowsinessStatus: String = "System requesting..."
    @State private var hasReceivedStatus = false
    @State private var showFailureAlert = false
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    // 토글 상태를 AppStorage로 유지
    @AppStorage("drowsyAlert") private var drowsyAlert = true
    @AppStorage("yawnAlert") private var yawnAlert = true
    @AppStorage("badMoodAlert") private var badMoodAlert = false
    @AppStorage("goodMoodAlert") private var goodMoodAlert = false
    
    @State private var previousStatus: String = ""
    @State private var listener: ListenerRegistration? // 추가
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("System requesting...")
                .font(.title2)
                .bold()
                .padding(.top)
            
            if showFailureAlert {
                Text("Drowsiness Detector System Failed.")
                    .foregroundColor(.red)
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
            } else {
                Text(drowsinessStatus)
                    .font(.title3)
                    // 포함되는 단어 들어오면 글씨 빨간색으로 변함
                    .foregroundColor(drowsinessStatus.contains("하품") ? .red : .blue)
                    .foregroundColor(drowsinessStatus.contains("감김") ? .red : .blue)
                    .bold()
            }
            
            Spacer()
            
            Button(action: stopButtonAction){
                Text("Stop System")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.8))
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

            // 1. ROS 2 종료 요청 → FastAPI
            sendEndDrowsinessRequest(uid: uid) { success in
                if success {
                    // 2. Firebase에 isActive=false 업데이트
                    stopDrowsinessDetector()
                    removeListener()
                    // 3. 화면 닫기
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
            
            if let data = snapshot?.data(), let alertStatus = data["alert_status"] as? String {
                drowsinessStatus = alertStatus
                hasReceivedStatus = true
                
                // 조건에 따라 음성 재생
                handleAlertStatus(alertStatus)
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
    private func handleAlertStatus(_ status: String) {
        DispatchQueue.main.async {
            guard status != previousStatus else { return }

            if status.contains("하품") && yawnAlert {
                SoundPlayer.shared.play(fileName: "alert1")
            } else if status.contains("감김") && drowsyAlert {
                SoundPlayer.shared.play(fileName: "drowsy_alert")
            } else if status.contains("기분 안 좋음") && badMoodAlert {
                SoundPlayer.shared.play(fileName: "negative_message")
            } else if status.contains("기분 좋음") && goodMoodAlert {
                SoundPlayer.shared.play(fileName: "positive_alert")
            }

            previousStatus = status
        }
    }
    
    func sendEndDrowsinessRequest(uid: String, completion: @escaping (Bool) -> Void) {
        let baseURL = AppConfig.shared.serverBaseURL
        guard let url = URL(string: "\(baseURL)/end_drowsiness") else {
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
                print("✅ end_drowsiness 요청 완료")
                completion(true)
            } else {
                print("❌ end_drowsiness 요청 실패:", error?.localizedDescription ?? "unknown")
                completion(false)
            }
        }.resume()
    }
    
    func stopDrowsinessDetector() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "isActive": false
        ]) { error in
            if let error = error {
                print("❌ 중단 실패: \(error.localizedDescription)")
            } else {
                print("🛑 졸음 인식 중지 신호 전송됨")
                isPresented = false
            }
        }
    }
    
    
    
    
    
    
    
    
}
