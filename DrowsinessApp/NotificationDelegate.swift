import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // ✅ 여기가 shared 싱글톤 정의
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
