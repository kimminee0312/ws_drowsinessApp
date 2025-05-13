import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DashboardView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Drowsiness Detector")
                .font(.title2)
                .bold()
                .foregroundColor(Color(.darkGray))
                .padding(.bottom, 20)
            
            Text("Start detecting drowsiness by tapping below")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}

