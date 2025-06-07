import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Lottie

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showingRegister = false
    @State private var isLoggedIn = false
    @State private var showLoading = false

    var body: some View {
        if showLoading {
            LoadingView()
        } else if isLoggedIn {
            MainTabView(isLoggedIn: $isLoggedIn)
                .background(Color.white.ignoresSafeArea())
        } else {
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Drowsiness Detector")
                        .bold()
                        .foregroundColor(Color(.darkGray)) // 어두운 회색
                        .font(.title2)
                    
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
        showLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // 약간 delay 주면 자연스러움
                showLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = ""
                    isLoggedIn = true
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            LottieView(filename: "loading") // .json 파일명
                .frame(width: 200, height: 200)
        }
    }
}

struct LottieView: UIViewRepresentable {
    var filename: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
