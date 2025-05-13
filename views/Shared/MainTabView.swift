import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct MainTabView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationView{
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                DrowsinessStartView()
                    .tabItem {
                        Label("Detector", systemImage: "desktopcomputer") 
                    }
                InsightsView()
                    .tabItem {
                        Label("Insights", systemImage: "chart.bar")
                    }
                
                SettingsView(isLoggedIn: $isLoggedIn)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
