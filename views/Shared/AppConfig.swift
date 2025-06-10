import Foundation

class AppConfig {
    static let shared = AppConfig()
    
    // FastAPI 서버 IP 주소
    var serverBaseURL: String = "http://172.20.10.3:8000"

    private init() {} // 외부에서 인스턴스 못 만들게 방지
}

