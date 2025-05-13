import SwiftUI

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
