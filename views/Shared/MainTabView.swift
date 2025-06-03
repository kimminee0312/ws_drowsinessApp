import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var statsVM = SessionViewModel(uid: "")   // ①

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }

            DrowsinessStartView()
                .tabItem { Label("Detector", systemImage: "desktopcomputer") }

            InsightsView()
                .environmentObject(statsVM)                       // ②
                .tabItem { Label("Insights", systemImage: "chart.bar") }

            SettingsView(isLoggedIn: $isLoggedIn)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .onAppear {           // ③ 앱이 보일 때 UID 한 번 주입
            if statsVM.uid.isEmpty,
               let u = Auth.auth().currentUser?.uid {
                statsVM.uid = u
            }
        }
    }
}
