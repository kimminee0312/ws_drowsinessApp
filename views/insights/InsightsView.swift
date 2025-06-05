import SwiftUI
import FirebaseAuth

struct InsightsView: View {
    @EnvironmentObject var vm: SessionViewModel
    @State private var showStats = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Insights")
                .font(.title2)
                .bold()
                .foregroundColor(Color(.darkGray)) // 어두운 회색
            
            Text(vm.uid.isEmpty ? "로딩중" : "사용자 정보 확인 완료")
                .foregroundColor(.gray)
            
            Button("Check Data") {
                if vm.uid.isEmpty,
                   let u = Auth.auth().currentUser?.uid { vm.uid = u }
                guard !vm.uid.isEmpty else { return }
                showStats = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(vm.uid.isEmpty ? Color.gray.opacity(0.4) : .blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(vm.uid.isEmpty)
            
            Spacer()
        }
        .padding()
        .preferredColorScheme(.light)
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showStats) {
            StatisticsView()
                .environmentObject(vm)
        }
    }
}

