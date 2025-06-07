import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab = 0 // 🔥 이거 추가
    @State private var tabReloadTrigger = UUID() // 추가
    @StateObject private var statsVM = SessionViewModel(uid: "")  
    @StateObject private var emotionVM = EmotionSessionViewModel(uid: "")

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            DrowsinessStartView()
                .tabItem { Label("Detector", systemImage: "desktopcomputer") }
                .tag(1)

            InsightsView()
                .environmentObject(statsVM)
                .environmentObject(emotionVM)
                .tabItem { Label("Insights", systemImage: "chart.bar") }
                .tag(2)

            SettingsView(isLoggedIn: $isLoggedIn)
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .id(tabReloadTrigger) // 🔥 TabView 자체를 강제로 새로 그림
        .transaction { t in
            t.disablesAnimations = true // 애니메이션 지연 방지
        }
        .onAppear {           // ③ 앱이 보일 때 UID 한 번 주입
            if statsVM.uid.isEmpty,
               let u = Auth.auth().currentUser?.uid {
                statsVM.uid = u
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                selectedTab = 0 // 강제 한번 탭 리셋
                tabReloadTrigger = UUID() // 🔥 TabView 전체 강제 reload
            }
        }
    }
}
