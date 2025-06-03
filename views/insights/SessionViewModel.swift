import Foundation
import FirebaseFirestore
import Combine

// MARK: - 일(日) 단위 집계 모델
struct DailySummary: Identifiable {
    let date: Date
    let safeAvg: Double
    let fatigueAvg: Double       // 평균 피로 점수
    let peakFatigueTime: Date?   // 가장 피로했던 시각 (Date)
    
    let blinkTotal: Int
    let yawnTotal: Int
    let yawnAvgDur: Double
    let sessions: [SessionData]
    
    var id: String { Self.dayF.string(from: date) }
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

// MARK: - ViewModel
@MainActor
final class SessionViewModel: ObservableObject {
    // ────────────── Published ──────────────
    @Published var uid: String {
        didSet { if !uid.isEmpty { fetchAllSessions() } }
    }
    @Published private(set) var sessions: [SessionData] = []
    @Published var errorMessage: String?
    
    // 하루 단위 요약
    var dailySummaries: [DailySummary] {
        Self.buildSummaries(from: sessions)
    }
    
    // ────────────── Private ──────────────
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()
    // 시간 문자열 파싱용 포맷터들
    private static let timeFormatter1: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "HH:mm:ss"; return f
    }()
    private static let timeFormatter2: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f
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
            guard let d = Self.dayF.date(from: dID) else {continue}
            let col = db.collection("users").document(uid)
                .collection("DrowsyData").document(dID)
                .collection("Sessions")
            
            grp.enter()
            col.getDocuments { snap, err in
                defer { grp.leave() }
                if let err { return }
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
        // start_time 형식이 "HH:mm:ss" 혹은 "HH:mm" 등일 수 있음
        let t1 = parseTime(from: a.start_time)
        let t2 = parseTime(from: b.start_time)
        guard let time1 = t1, let time2 = t2 else { return false }
        return time1 < time2
    }
    
    // 시간 문자열 파싱 헬퍼
    private static func parseTime(from str: String) -> Date? {
        if let d = timeFormatter1.date(from: str) { return d }
        return timeFormatter2.date(from: str)
    }
    
    private static func buildSummaries(from list: [SessionData]) -> [DailySummary] {
        let grouped = Dictionary(grouping: list) {
            $0.date.map { dayF.string(from: $0) } ?? "NA"
        }
        
        return grouped.compactMap { dateString, ss -> DailySummary? in
            guard let dayDate = ss.first?.date else { return nil }
            
            // 평균·합계
            let safeAvg    = ss.map(\.safe_score).average()
            let fatigueAvg = ss.map(\.fatigue_score).average()
            let blinkSum   = ss.map(\.drowsy_eye_closed).reduce(0, +)
            let yawnSum    = ss.map(\.yawns).reduce(0, +)
            let yawnAvg    = ss.map(\.avg_yawn_duration).average()
            
            // “peak_drowsy_time”이 유효한 세션만 필터
            let validSessions = ss.filter { session in
                let t = session.peak_drowsy_time
                if t.trimmingCharacters(in: .whitespaces).isEmpty { return false }
                return parseTime(from: t) != nil
            }
            
            // 유효한 세션 중 피로도 최대값 세션 선택
            let peakSession = validSessions.max(by: {
                $0.fatigue_score < $1.fatigue_score
            })
            
            // 파싱된 Date 생성
            var peakDate: Date? = nil
            if let tStr = peakSession?.peak_drowsy_time,
               let timePart = parseTime(from: tStr) {
                let cal = Calendar.current
                peakDate = cal.date(
                    bySettingHour:   cal.component(.hour,   from: timePart),
                    minute:          cal.component(.minute, from: timePart),
                    second:          cal.component(.second, from: timePart),
                    of:              dayDate
                )
            }
            
            return DailySummary(
                date:            dayDate,
                safeAvg:         safeAvg,
                fatigueAvg:      fatigueAvg,
                peakFatigueTime: peakDate,
                blinkTotal:      blinkSum,
                yawnTotal:       yawnSum,
                yawnAvgDur:      yawnAvg,
                sessions:        ss
            )
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - Small helpers
private extension Collection where Element == Double {
    func average() -> Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}
private extension Collection where Element: BinaryInteger {
    func average() -> Double { isEmpty ? 0 : Double(reduce(0, +)) / Double(count) }
}
