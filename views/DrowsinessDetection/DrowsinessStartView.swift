import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DrowsinessStartView: View {
    @State private var showStatusScreen = false
    @State private var showFaceRegistrationAlert = false

    var body: some View {
        VStack() {
            Spacer()
            
            Text("Drowsiness Dector")
                .font(.title2)
                .foregroundColor(Color(.darkGray)) // 어두운 회색
                .bold()

            Button(action: {
                checkFaceRegistrationAndStart()
            }) {
                Text("System Start")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .fullScreenCover(isPresented: $showStatusScreen) {
            StatusView(isPresented: $showStatusScreen)
        }
        .alert(isPresented: $showFaceRegistrationAlert) {
            Alert(title: Text("Face not registered"), message: Text("Please register your face first"), dismissButton: .default(Text("check")))
        }
    }
    
    func checkFaceRegistrationAndStart() {
        guard let Uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(Uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let registered = data["face_id_registered"] as? Bool {
                if registered {
                    drowsinessDetector()
                    showStatusScreen = true
                } else {
                    showFaceRegistrationAlert = true
                }
            } else {
                showFaceRegistrationAlert = true
            }
        }
    }
    
    // DrowsinessDetector start sign
    func drowsinessDetector() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // prefix 추가
        let prefixedUid = "[drowsy]" + uid

        // FastAPI 주소
        let url = URL(string: "http://172.20.10.3:8000/start_drowsiness")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["uid": prefixedUid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 졸음 인식 요청 실패: \(error.localizedDescription)")
            } else {
                print("✅ 졸음 인식 요청 전송 완료")
            }
        }.resume()
    }
}
