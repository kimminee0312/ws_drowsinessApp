import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
