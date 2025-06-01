import Foundation

class AppConfig {
    static let shared = AppConfig()
    
    // FastAPI 서버 IP 주소 (Wi-Fi 연결 시 바뀔 수 있음)
    var serverBaseURL: String = "http://192.168.20.79:8000"
    
    private init() {} // 외부에서 인스턴스 못 만들게 방지
}

