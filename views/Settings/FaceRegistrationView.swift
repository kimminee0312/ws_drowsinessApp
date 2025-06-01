import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct FaceRegistrationView: View {
    @Binding var isRegistered: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Label("Back", systemImage: "chevron.left")
                        .foregroundColor(.blue)
                }
                .padding()

                Spacer()
            }
            
            Text("Register Face")
                .font(.title2)
                .foregroundColor(Color(.darkGray)) // 어두운 회색
                .bold()
            
            Spacer()
            
            Button("Face Registration Request") {
                sendEmailToFastAPIServer()
            }
            Spacer()
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }

    func sendEmailToFastAPIServer() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("====== 로그인된 이메일 없음 ======")
            return
        }
        //prefix 추가
        let prefixedUid = "[face_register]" + uid
        
        //FastAPI 주소
        let baseURL = AppConfig.shared.serverBaseURL
        let url = URL(string: "\(baseURL)/face_register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["uid": prefixedUid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("====== 네트워크 에러: \(error.localizedDescription) ======")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("====== FastAPI 응답 코드: \(httpResponse.statusCode) ======")
            }
            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("====== 서버 응답: \(responseText) ======")
            }
        }.resume()
    }
}
