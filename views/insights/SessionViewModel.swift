import Foundation
import FirebaseFirestore
import Combine

// MARK: - 일(日) 단위 집계 모델
struct DailySummary: Identifiable {
    let date: Date
    let safeAvg: Double
    let blinkTotal: Int
    let yawnTotal: Int
    let peakTime: String?
    let yawnAvgDur: Double
    let sessions: [SessionData]
    
    var id: String { Self.dayF.string(from: date) }
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
}

@MainActor
final class SessionViewModel: ObservableObject {
    // ────────────── Published ──────────────
    @Published var uid: String {
        didSet { if !uid.isEmpty { fetchAllSessions() } }
    }
    @Published private(set) var sessions: [SessionData] = []
    @Published var errorMessage: String?
    
    // “하루 단위 요약” → 뷰에서 직접 사용
    var dailySummaries: [DailySummary] { Self.buildSummaries(from: sessions) }
    
    // ────────────── Private ──────────────
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    private static let timeF: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "HH:mm:ss"; return f
    }()
    
    // ────────────── LifeCycle ──────────────
    init(uid: String) {
        self.uid = uid
        if !uid.isEmpty { fetchAllSessions() }
    }
    deinit { listeners.forEach { $0.remove() } }
    
    // ────────────── Firestore 로딩 ──────────────
    private func fetchAllSessions() {
        guard !uid.isEmpty else { return }
        
        let col = db.collection("users").document(uid).collection("DrowsyData")
        col.getDocuments(source: .server) { [weak self] snap, err in
            guard let self else { return }
            if let err { self.errorMessage = err.localizedDescription; return }
            let dayIDs = snap?.documents.map(\.documentID) ?? []
            self.listenSessions(for: dayIDs)
        }
    }
    
    private func listenSessions(for dayIDs: [String]) {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        
        var all: [SessionData] = []
        let grp = DispatchGroup()
        
        for dID in dayIDs {
            guard let d = Self.dayF.date(from: dID) else { continue }
            let col = db.collection("users").document(uid)
                .collection("DrowsyData").document(dID)
                .collection("Sessions")
            
            grp.enter()
            col.getDocuments { snap, err in
                defer { grp.leave() }
                if let err { print("🔥 \(dID) 세션 err", err); return }
                for doc in snap?.documents ?? [] {
                    if var s = try? doc.data(as: SessionData.self) {
                        s.date = d
                        all.append(s)
                    }
                }
            }
        }
        
        grp.notify(queue: .main) {
            self.sessions = all.sorted(by: Self.sessionSorter)
        }
    }
    
    // ────────────── Utilities ──────────────
    private static func sessionSorter(_ a: SessionData, _ b: SessionData) -> Bool {
        if let d1 = a.date, let d2 = b.date, d1 != d2 { return d1 < d2 }
        guard let t1 = timeF.date(from: a.start_time),
              let t2 = timeF.date(from: b.start_time) else { return false }
        return t1 < t2
    }
    
    private static func buildSummaries(from list: [SessionData]) -> [DailySummary] {
        let grouped = Dictionary(grouping: list) { $0.date.map { dayF.string(from:$0) } ?? "NA" }
        
        return grouped.compactMap { _, ss -> DailySummary? in
            guard let anyDate = ss.first?.date else { return nil }
            let safeAvg  = ss.map(\.safe_score).average()
            let blinkSum = ss.map(\.drowsy_eye_closed).reduce(0, +)
            let yawnSum  = ss.map(\.yawns).reduce(0, +)
            let yawnAvg  = ss.map(\.avg_yawn_duration).average()
            let peak     = ss.min(by: { $0.safe_score < $1.safe_score })?.peak_drowsy_time
            
            return DailySummary(date: anyDate,
                                safeAvg: safeAvg,
                                blinkTotal: blinkSum,
                                yawnTotal: yawnSum,
                                peakTime: peak,
                                yawnAvgDur: yawnAvg,
                                sessions: ss)
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - Small helpers
private extension Collection where Element == Double {
    func average() -> Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}
private extension Collection where Element : BinaryInteger {
    func average() -> Double { isEmpty ? 0 : Double(reduce(0, +)) / Double(count) }
}
