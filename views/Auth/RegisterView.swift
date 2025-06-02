import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
                        .onChange(of: password) {
                            isPasswordEntered = !password.isEmpty
                        }
                    
                    if isPasswordEntered{
                        CustomPlaceholderTextField(placeholder: "Confirm Password", text: $confirmPassword)
                            .frame(height: 44)
                            .padding(.horizontal)
                            .background(Color(UIColor.lightGray).opacity(0.2))
                            .cornerRadius(8)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isPasswordEntered)
                    } else {
                        EmptyView()
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
            } else if let user = result?.user {
                let db = Firestore.firestore()
                let Uid = user.uid
                db.collection("users").document(Uid).setData([
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

