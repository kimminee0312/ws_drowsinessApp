import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - 일(日) 단위 감정 집계 모델
struct DailyEmotionSummary: Identifiable {
    let date: Date
    let avgEmotionScore: Double
    let dominantEmotion: String
    let sessions: [EmotionSessionData]
    
    var id: String { Self.dayF.string(from: date) }
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

struct EmotionSessionData: Identifiable, Codable {
    @DocumentID var id: String? // session_id
    var emotion_score: Double
    var emotion_summary: String
    
    var date: Date? // Sessions 상위 날짜 기준
}

@MainActor
final class EmotionSessionViewModel: ObservableObject {
    @Published var uid: String {
        didSet { if !uid.isEmpty { fetchAllSessions() } }
    }
    @Published private(set) var sessions: [EmotionSessionData] = []
    @Published private(set) var emotionSummaries: [EmotionSummary] = []
    @Published var errorMessage: String?
    
    var dailyEmotionSummaries: [DailyEmotionSummary] {
        Self.buildDailySummaries(from: sessions)
    }
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    
    init(uid: String) {
        self.uid = uid
        if !uid.isEmpty { fetchAllSessions() }
    }
    
    deinit { listeners.forEach { $0.remove() } }
    
    func fetchAllSessions() {
        print("[DEBUG] fetchAllSessions called")
        print("[DEBUG] uid: \(uid)")

        guard !uid.isEmpty else { return }

        let col = db.collection("users").document(uid).collection("EmotionData")
        col.getDocuments { [weak self] (snap: QuerySnapshot?, err: Error?) in
            guard let self else { return }
            print("[DEBUG] inside getDocuments callback")
            if let err {
                print("[DEBUG] Error: \(err.localizedDescription)")
                self.errorMessage = err.localizedDescription
                return
            }

            print("[DEBUG] documents count: \(snap?.documents.count ?? 0)")
            
            let dayIDs = snap?.documents.map(\.documentID) ?? []
            self.listenSessions(for: dayIDs)
        }
    }

    private func listenSessions(for dayIDs: [String]) {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        
        var all: [EmotionSessionData] = []
        let grp = DispatchGroup()
        
        for dID in dayIDs {
            guard let d = Self.dayF.date(from: dID) else { continue }
            let col = db.collection("users").document(uid)
                .collection("EmotionData").document(dID)
                .collection("Sessions")
            
            grp.enter()
            col.getDocuments { snap, err in
                defer { grp.leave() }
                if err != nil { return }
                for doc in snap?.documents ?? [] {
                    if var s = try? doc.data(as: EmotionSessionData.self) {
                        s.date = d
                        all.append(s)
                    }
                }
            }
        }
        
        grp.notify(queue: .main) {
            print("[DEBUG] Loaded sessions count: \(all.count)")
            self.sessions = all.sorted(by: Self.sessionSorter)
            self.updateEmotionSummariesFromSessions() // ⭐️ 업데이트 추가
        }
    }
    
    private func updateEmotionSummariesFromSessions() {
        self.emotionSummaries = self.sessions.map { session in
            EmotionSummary(
                id: session.id ?? UUID().uuidString,
                date: session.date ?? Date(timeIntervalSince1970: 0),
                emotionScore: session.emotion_score,
                emotionSummary: session.emotion_summary
            )
        }
        .sorted { $0.date < $1.date }
    }
    
    private static func sessionSorter(_ a: EmotionSessionData, _ b: EmotionSessionData) -> Bool {
        if let d1 = a.date, let d2 = b.date, d1 != d2 { return d1 < d2 }
        return false
    }
    
    private static func buildDailySummaries(from list: [EmotionSessionData]) -> [DailyEmotionSummary] {
        let grouped = Dictionary(grouping: list) {
            dayF.string(from: $0.date ?? Date(timeIntervalSince1970: 0))
        }
        
        return grouped.compactMap { dateString, ss -> DailyEmotionSummary? in
            guard let dayDate = dayF.date(from: dateString) else { return nil }
            
            let avgEmotionScore = ss.map(\.emotion_score).filter { $0.isFinite }.average()
            
            let dominantEmotion = ss.map(\.emotion_summary)
                .reduce(into: [:]) { counts, summary in
                    counts[summary, default: 0] += 1
                }
                .max(by: { $0.value < $1.value })?.key ?? "Unknown"
            
            return DailyEmotionSummary(
                date: dayDate,
                avgEmotionScore: avgEmotionScore,
                dominantEmotion: dominantEmotion,
                sessions: ss
            )
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - Small helpers
private extension Collection where Element == Double {
    func average() -> Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}
