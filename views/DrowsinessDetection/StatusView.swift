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
                    .font(.title)
                    // 포함되는 단어 들어오면 글씨 빨간색으로 변함
                    .foregroundColor(drowsinessStatus.contains("하품") ? .red : .blue)
                    .foregroundColor(drowsinessStatus.contains("감김") ? .red : .blue)
                    .bold()
            }
            
            Spacer()
            
            Button(action: {
                if let user = Auth.auth().currentUser {
                    let uid = user.uid

                    // 1. ROS 2 종료 요청 → FastAPI
                    sendEndDrowsinessRequest(uid: uid) { success in
                        if success {
                            // 2. Firebase에 isActive=false 업데이트
                            stopDrowsinessDetector()
                            
                            // 3. 화면 닫기
                            DispatchQueue.main.async {
                                dismiss()
                            }
                        } else {
                            print("❗️종료 요청 실패")
                        }
                    }
                }
            }) {
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
        .background(Color.white.ignoresSafeArea())
    }
    
    func listenToStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docRef = Firestore.firestore().collection("users").document(uid)
        
        docRef.addSnapshotListener { snapshot, error in
            if let data = snapshot?.data(), let alertStatus = data["alert_status"] as? String {
                drowsinessStatus = alertStatus
                hasReceivedStatus = true
            }
        }
        //20초 안에 status가 안 오면 실패 간주
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !hasReceivedStatus {
                showFailureAlert = true
            }
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
