// Auto-login Extension
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

extension Auth {
    static func loginWithSavedCredentials(completion: @escaping (Bool) -> Void) {
        if let email = UserDefaults.standard.string(forKey: "savedEmail"),
           let password = UserDefaults.standard.string(forKey: "savedPassword") {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
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
