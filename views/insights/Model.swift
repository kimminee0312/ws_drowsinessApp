// Model.swift
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
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case start_time
        case end_time
        case drowsy_eye_closed
        case yawns
        case avg_yawn_duration
        case peak_drowsy_time
        case fatigue_score
        case safe_score
    }
}
