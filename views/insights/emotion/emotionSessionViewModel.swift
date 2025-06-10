import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: - 일(日) 단위 감정 집계 모델
struct DailyEmotionSummary: Identifiable {
    let date: Date
    let avgEmotionScore: Double
    let dominantEmotion: String
    let emotionSessions: [EmotionSessionData]
    let startTime: String
    let endTime: String
    let positiveDuration: Double
    let neutralDuration: Double
    let negativeDuration: Double

    var id: String { Self.dayFormatter.string(from: date) }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

@MainActor
final class EmotionSessionViewModel: ObservableObject {
    // MARK: Published
    @Published var uid: String {
        didSet {
            if !uid.isEmpty { fetchAllSessions() }
        }
    }
    @Published private(set) var emotionSessions: [EmotionSessionData] = []
    @Published var errorMessage: String?

    var dailyEmotionSummaries: [DailyEmotionSummary] {
        Self.buildDailySummaries(from: emotionSessions)
    }

    // MARK: Private
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    private static let timeFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    private static let timeFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // MARK: Lifecycle
    init(uid: String) {
        self.uid = uid
        if !uid.isEmpty { fetchAllSessions() }
    }

    deinit {
        listeners.forEach { $0.remove() }
    }

    // MARK: Firestore Fetch
    func fetchAllSessions() {
        guard !uid.isEmpty else { return }
        let collection = db.collection("users").document(uid).collection("EmotionData")
        collection.getDocuments(source: .server) { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            let dayIDs = snapshot?.documents.map { $0.documentID } ?? []
            self.listenSessions(for: dayIDs)
        }
    }

    private func listenSessions(for dayIDs: [String]) {
        listeners.forEach { $0.remove() }
        listeners.removeAll()

        var allSessions: [EmotionSessionData] = []
        let dispatchGroup = DispatchGroup()

        for dayID in dayIDs {
            guard let date = Self.dayFormatter.date(from: dayID) else { continue }
            let collection = db.collection("users").document(uid)
                .collection("EmotionData").document(dayID)
                .collection("Sessions")

            dispatchGroup.enter()
            collection.getDocuments { snapshot, error in
                defer { dispatchGroup.leave() }
                guard error == nil else { return }
                for doc in snapshot?.documents ?? [] {
                    if var session = try? doc.data(as: EmotionSessionData.self) {
                        session.date = date
                        allSessions.append(session)
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.emotionSessions = allSessions.sorted(by: Self.sessionSorter)
        }
    }

    // MARK: Utilities
    private static func sessionSorter(_ a: EmotionSessionData, _ b: EmotionSessionData) -> Bool {
        if let dateA = a.date, let dateB = b.date, dateA != dateB {
            return dateA < dateB
        }
        guard let timeA = parseTime(from: a.start_time), let timeB = parseTime(from: b.start_time) else {
            return false
        }
        return timeA < timeB
    }

    private static func parseTime(from string: String) -> Date? {
        if let date = timeFormatter1.date(from: string) {
            return date
        }
        return timeFormatter2.date(from: string)
    }

    private static func buildDailySummaries(from sessions: [EmotionSessionData]) -> [DailyEmotionSummary] {
        let grouped = Dictionary(grouping: sessions) { session in
            dayFormatter.string(from: session.date ?? .distantPast)
        }

        return grouped.compactMap { dayString, sessions in
            guard let dayDate = dayFormatter.date(from: dayString) else { return nil }

            // Avg emotion score
            let scores = sessions.map { $0.emotion_score }.filter { $0.isFinite }
            let avgScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)

            // Dominant emotion
            let dominant = sessions
                .map { $0.emotion_summary }
                .reduce(into: [:]) { counts, emo in
                    counts[emo, default: 0] += 1
                }
                .max(by: { $0.value < $1.value })?
                .key ?? "Unknown"

            // 세션 필드 기반 총 지속시간
            let positiveDuration = sessions.map { $0.positive_duration ?? 0 }.reduce(0, +)
            let neutralDuration  = sessions.map { $0.neutral_duration  ?? 0 }.reduce(0, +)
            let negativeDuration = sessions.map { $0.negative_duration ?? 0 }.reduce(0, +)
            // 일일 시작/종료 시간 (옵션)
            let starts = sessions.compactMap { parseTime(from: $0.start_time) }
            let ends   = sessions.compactMap { parseTime(from: $0.end_time)   }
            let calendar = Calendar.current
            let earliestStart = starts.min().flatMap { calStart in
                calendar.date(bySettingHour: calendar.component(.hour, from: calStart),
                              minute: calendar.component(.minute, from: calStart),
                              second: calendar.component(.second, from: calStart), of: dayDate)
            }
            let latestEnd = ends.max().flatMap { calEnd in
                calendar.date(bySettingHour: calendar.component(.hour, from: calEnd),
                              minute: calendar.component(.minute, from: calEnd),
                              second: calendar.component(.second, from: calEnd), of: dayDate)
            }
            let startTimeStr = earliestStart.map { timeFormatter1.string(from: $0) } ?? ""
            let endTimeStr   = latestEnd.map   { timeFormatter1.string(from: $0) } ?? ""

            return DailyEmotionSummary(
                date: dayDate,
                avgEmotionScore: avgScore,
                dominantEmotion: dominant,
                emotionSessions: sessions,
                startTime: startTimeStr,
                endTime: endTimeStr,
                positiveDuration: positiveDuration,
                neutralDuration: neutralDuration,
                negativeDuration: negativeDuration
            )
        }
        .sorted { $0.date < $1.date }
    }
}

private extension Collection where Element == Double {
    func average() -> Double { isEmpty ? 0 : reduce(0, +) / Double(count) }
}
