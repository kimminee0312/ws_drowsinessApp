import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @State private var faceIdRegistered = false // 임의로 등록 했다고 가정 =========================
    @State private var showFaceRegistration = false
    @State private var showNotificationSettingsView = false
    @State private var showAboutView = false

    var body: some View {
        VStack() {
            Spacer()
            
            Text("Settings")
                .font(.title2)
                .bold()
                .foregroundColor(Color(.darkGray)) // 어두운 회색
                .padding(.bottom, 20)
            
            Text("얼굴 등록")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 3)
            
            if !faceIdRegistered {
                Button(action: {
                    showFaceRegistration = true
                }) {
                    HStack {
                        Text("Register Face")
                        if !faceIdRegistered {
                            Spacer()
                            Text("Required")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $showFaceRegistration) {
                    FaceRegistrationView(isRegistered: $faceIdRegistered)
                }
            } else {
                HStack {
                    Text("Face registration completed")
                        .foregroundColor(.green)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            
            Text("사운드 설정")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 3)
                .padding(.top, 15)

            Button(action: {
                showNotificationSettingsView = true
            }) {
                Text("Notification Settings")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showNotificationSettingsView) {
                NotificationSettingsView()
            }
            
            Button(action: {
                showAboutView = true
            }) {
                Text("Technology Implementation")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2) // 파란색 테두리 추가
                    )
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .padding(.top, 30)
            }
            .sheet(isPresented: $showAboutView) {
                AboutView()
            }
            Button(action: logout) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.5))
                    .fontWeight(.bold)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            loadFaceIdStatus()
        }
    }

    func loadFaceIdStatus() {
        guard let Uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(Uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let registered = data["face_id_registered"] as? Bool {
                faceIdRegistered = registered
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "savedEmail")
            UserDefaults.standard.removeObject(forKey: "savedPassword")
            isLoggedIn = false
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
}
