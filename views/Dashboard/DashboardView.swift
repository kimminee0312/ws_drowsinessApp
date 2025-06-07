import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DashboardView: View {
    @State private var reloadTrigger = UUID()

    
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Drowsiness Detector")
                .font(.title2)
                .bold()
                .foregroundColor(Color(.darkGray))
            
            Text("Demo version")
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.bottom, 20)
                .padding(.top, 10)
            
            VStack(alignment: .leading) {
                Text("How to Use")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 4)

                Text("1. Register your face in the Settings tab.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("2. Start the drowsy/emotion detection system.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("3. You can view your history in the Insights tab.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            Spacer()
            
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .preferredColorScheme(.light) // 💡 다크모드에서도 항상 light로 강제 고정
        .id(reloadTrigger) // 🔥 강제로 View를 refresh
        .onAppear {
            reloadTrigger = UUID() // 🔥 DashboardView 진입 시마다 새로 로드
        }
    }
}

