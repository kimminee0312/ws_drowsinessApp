//  DrowsinessAppApp.swift
//  DrowsinessApp

import Firebase
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@main
struct DrowsinessAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            SplashView()
                .background(Color.white.ignoresSafeArea())
        }
    }
}

// Firebase 초기화
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

