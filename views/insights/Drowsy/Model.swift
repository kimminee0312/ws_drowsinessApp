import Foundation
import FirebaseFirestore

struct SessionData: Identifiable, Codable {
    @DocumentID var id: String?
    let start_time: String
    let end_time: String
    let drowsy_eye_closed: Int
    let yawns: Int
    let avg_yawn_duration: Double
    let peak_drowsy_time: String
    let fatigue_score: Int
    let safe_score: Int
    var date: Date?          // 상위 문서 날짜 주입용
    
    enum CodingKeys: String, CodingKey {
        case id, start_time, end_time,
             drowsy_eye_closed, yawns, avg_yawn_duration,
             peak_drowsy_time, fatigue_score, safe_score
    }
}
