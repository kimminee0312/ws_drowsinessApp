//  DrowsinessAppApp.swift
//  DrowsinessApp

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@main
struct DrowsinessAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            SplashView()
                .background(Color.white.ignoresSafeArea())
        }
    }
}

// Firebase 초기화
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

import SwiftUI

struct CustomPlaceholderTextField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String
    var placeholderColor: UIColor = .gray
    var textColor: UIColor = .black

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor,
                .font: UIFont.systemFont(ofSize: 13)
            ]
        )
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        @objc func textDidChange(_ sender: UITextField) {
            text.wrappedValue = sender.text ?? ""
        }
    }
}

// 스플래시 화면
struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if isActive {
                LoginView()
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image("konkuk_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .opacity(0.8)
                    
                    Text("Drowsiness Detector App")
                        .bold()
                        .foregroundColor(Color(.darkGray)) // 어두운 회색
                        .font(.title2)
                    
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

// 로그인 화면
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showingRegister = false
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView(isLoggedIn: $isLoggedIn)
                .background(Color.white.ignoresSafeArea())
        } else {
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    CustomPlaceholderTextField(placeholder: "Email", text: $email)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .keyboardType(.emailAddress)
                        .cornerRadius(8)
                    
                    CustomPlaceholderTextField(placeholder: "Password", text: $password)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(8)
                    
                    Button(action: login) {
                        Text("LOGIN")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                Spacer()

                Button("회원가입") {
                    showingRegister = true
                }
                .foregroundColor(.blue)
                .sheet(isPresented: $showingRegister) {
                    RegisterView()
                }
            }
            .padding()
            .background(Color.white.ignoresSafeArea())
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = ""
                isLoggedIn = true
            }
        }
    }
}

// 회원가입 화면
struct RegisterView: View {
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birth = ""
    @State private var phone = ""
    @State private var errorMessage = ""
    @State private var isPasswordEntered = false

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                
                Text("회원가입")
                    .bold()
                    .foregroundColor(Color(.darkGray)) // 어두운 회색
                    .font(.title2)
                
                Group {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CustomPlaceholderTextField(placeholder: "First Name(이름)", text: $firstName)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(8)
                    CustomPlaceholderTextField(placeholder: "Last Name(성)", text: $lastName)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("Birth")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CustomPlaceholderTextField(placeholder: "1900/00/00", text: $birth)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("Phone Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CustomPlaceholderTextField(placeholder: "010-0000-0000", text: $phone)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CustomPlaceholderTextField(placeholder: " ", text: $email)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .keyboardType(.emailAddress)
                        .cornerRadius(8)
                    
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CustomPlaceholderTextField(placeholder: " ", text: $password)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .background(Color(UIColor.lightGray).opacity(0.2))
                        .cornerRadius(8)
                        .onChange(of: password) { newValue in
                            isPasswordEntered = !newValue.isEmpty
                        }
                    
                    if isPasswordEntered{
                        CustomPlaceholderTextField(placeholder: "Confirm Password", text: $confirmPassword)
                            .frame(height: 44)
                            .padding(.horizontal)
                            .background(Color(UIColor.lightGray).opacity(0.2))
                            .cornerRadius(8)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isPasswordEntered)
                    }
                }
                
                Button("Enter") {
                    register()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Spacer(minLength: 50)
            }
            .padding()
            .background(Color.white.ignoresSafeArea())
        }
    }

    func register() {
        guard password == confirmPassword else {
            errorMessage = "Password and password check do not match."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "The Password must be 6 characters long."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("🔥 Firebase Error: \(error.localizedDescription)")
                print("📦 Full error: \(error)") // 여기에 진짜 상세 정보 나옴
                errorMessage = error.localizedDescription
            } else if result?.user != nil {
                let db = Firestore.firestore()
                let docId = email.lowercased().replacingOccurrences(of: " ", with: "")
                db.collection("users").document(docId).setData([
                    "First Name": firstName,
                    "Last Name": lastName,
                    "Birth": birth,
                    "Phone": phone,
                    "Email": email
                ]) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Drowsiness Detector start screen
struct DashboardView: View {
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
        guard let docId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(docId).getDocument { snapshot, error in
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
        let db = Firestore.firestore()
        guard let docId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(docId).updateData([
            "isActive": true
        ]) { error in
            if let error = error {
                print("❌ Firestore 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("✅ 졸음 인식 시작 신호 전송됨")
            }
        }
    }
}

//DrowsinessDetector status sub screen
struct StatusView: View {
    @State private var drowsinessStatus: String = "로딩 중..."
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
            
            Text("졸음 인식 상태")
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
                    .foregroundColor(drowsinessStatus.contains("drowsiness") ? .red : .blue)
                    .foregroundColor(drowsinessStatus.contains("졸음") ? .red : .blue)
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
        guard let docId = Auth.auth().currentUser?.uid else { return }
        let docRef = Firestore.firestore().collection("users").document(docId)
        
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
        guard let docId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(docId).updateData([
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

//Histroy screen
struct HistoryView: View {
    @State private var records: [String] = []
    @State private var isLoading = true

    var body: some View {
        VStack() {
            Spacer()
            
            Text("Drowsiness Detection History")
                .font(.title2)
                .bold()
                .foregroundColor(Color(.darkGray)) // 어두운 회색
                .padding(.top)

            if isLoading {
                ProgressView()
                    .padding()
            } else if records.isEmpty {
                Spacer()
                Text("No record")
                    .foregroundColor(.gray)
                    .font(.body)
                Spacer()
            } else {
                List(records, id: \.self) { record in
                    Text(record)
                }
            }
            
            Spacer()
        }
        .onAppear(perform: loadHistory)
        .background(Color.white.ignoresSafeArea())
    }

    func loadHistory() {
        guard let docId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(docId).collection("history")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                if let documents = snapshot?.documents {
                    records = documents.map { doc in
                        let status = doc["status"] as? String ?? "Unknown"
                        let timestamp = doc["timestamp"] as? Timestamp ?? Timestamp()
                        let dateStr = DateFormatter.localizedString(from: timestamp.dateValue(), dateStyle: .short, timeStyle: .short)
                        return "[\(dateStr)] - \(status)"
                    }
                }
            }
    }
}

// Settings screen
struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    @State private var faceIdRegistered = false // 임의로 등록 했다고 가정 =========================
    @State private var showFaceRegistration = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Settings")
                .font(.title2)
                .bold()
                .foregroundColor(Color(.darkGray)) // 어두운 회색
            
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
            
            Button(action: logout) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
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
        guard let docId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(docId).getDocument { snapshot, error in
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

// Face Registration View
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
        guard let email = Auth.auth().currentUser?.email else {
            print("====== 로그인된 이메일 없음 ======")
            return
        }

        let url = URL(string: "http://172.20.10.10:8000/email")!  // 여기에 서버 IP 주소
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email]
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


// Auto-login Extension
extension Auth {
    static func loginWithSavedCredentials(completion: @escaping (Bool) -> Void) {
        if let email = UserDefaults.standard.string(forKey: "savedEmail"),
           let password = UserDefaults.standard.string(forKey: "savedPassword") {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("자동 로그인 실패: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }

    static func saveCredentials(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "savedEmail")
        UserDefaults.standard.set(password, forKey: "savedPassword")
    }
}

// 메인 탭 뷰 (로그인 성공 후에만 사용됨)
struct MainTabView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Detector", systemImage: "house")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            SettingsView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
