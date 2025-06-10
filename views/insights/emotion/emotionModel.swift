import Foundation
import FirebaseFirestore

struct EmotionSessionData: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date?
    let emotion_score: Double
    let emotion_summary: String
    let end_time: String
    let negative_duration:Double
    let neutral_duration: Double
    let positive_duration: Double
    let start_time: String
    
}
