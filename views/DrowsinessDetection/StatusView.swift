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
            
            Button(action: stopDrowsinessDetector) {
                Text("System Stop")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear(perform: listenToStatus)
        .background(Color.white.ignoresSafeArea())
    }
    
    func listenToStatus() {
        guard let Email = Auth.auth().currentUser?.email else { return }
        let docRef = Firestore.firestore().collection("users").document(Email)
        
        docRef.addSnapshotListener { snapshot, error in
            if let data = snapshot?.data(), let status = data["status"] as? String {
                drowsinessStatus = status
                hasReceivedStatus = true
            }
        }
        //5초 안에 status가 안 오면 실패 간주
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !hasReceivedStatus {
                showFailureAlert = true
            }
        }
    }
    func stopDrowsinessDetector() {
        guard let Email = Auth.auth().currentUser?.email else { return }
        let db = Firestore.firestore()
        db.collection("users").document(Email).updateData([
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
