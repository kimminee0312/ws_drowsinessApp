// SessionViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class SessionViewModel: ObservableObject {
    @Published var sessions: [SessionData] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private let uid: String

    init(uid: String) {
        self.uid = uid
        fetchAllSessions()
    }

    deinit {
        listeners.forEach { $0.remove() }
    }

    private func fetchAllSessions() {
        let drowsyDataCol = db
            .collection("users")
            .document(uid)
            .collection("DrowsyData")

        let dateListener = drowsyDataCol.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = "[DrowsyData Listener] \(error.localizedDescription)"
                print(self.errorMessage!)
                return
            }
            guard let docs = snapshot?.documents else {
                print("날짜 컬렉션에 문서가 없습니다.")
                return
            }
            let dateStrings = docs.map { $0.documentID } // ["2025-06-02", ...]
            print("가져온 날짜 목록: \(dateStrings)")
            self.listenToSessions(for: dateStrings)
        }
        listeners.append(dateListener)
    }

    private func listenToSessions(for dateList: [String]) {
        // 기존 listener 모두 해제
        listeners.forEach { $0.remove() }
        listeners.removeAll()

        var combined: [SessionData] = []
        let dispatchGroup = DispatchGroup()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for dateStr in dateList {
            guard let docDate = dateFormatter.date(from: dateStr) else { continue }
            dispatchGroup.enter()

            let sessionsCol = db
                .collection("users")
                .document(uid)
                .collection("DrowsyData")
                .document(dateStr)
                .collection("Sessions")

            sessionsCol.getDocuments { snapshot, error in
                defer { dispatchGroup.leave() }  // 반드시 notify 전에 leave 호출
                if let error = error {
                    print("[Sessions(\(dateStr))] 오류: \(error.localizedDescription)")
                    return
                }
                guard let docs = snapshot?.documents else {
                    print("Sessions(\(dateStr))가 비어 있거나 없습니다.")
                    return
                }
                print("Sessions(\(dateStr)) 문서 개수: \(docs.count)")

                for doc in docs {
                    do {
                        // 자동 Codable 디코딩
                        var session = try doc.data(as: SessionData.self)
                        session.date = docDate
                        combined.append(session)
                        print("  • 세션 읽음: id=\(session.id ?? "nil"), safe_score=\(session.safe_score)")
                    } catch {
                        print("  [디코딩 오류] dateStr=\(dateStr), docID=\(doc.documentID): \(error)")
                    }
                }
            }
        }

        // 모든 서브컬렉션 getDocuments 콜백이 끝나면 notify 실행
        dispatchGroup.notify(queue: .main) {
            // 날짜+시작 시간 순으로 정렬
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            self.sessions = combined.sorted { lhs, rhs in
                if let d1 = lhs.date, let d2 = rhs.date, d1 != d2 {
                    return d1 < d2
                }
                guard
                    let t1 = timeFormatter.date(from: lhs.start_time),
                    let t2 = timeFormatter.date(from: rhs.start_time)
                else { return false }
                return t1 < t2
            }
            print("최종 sessions 배열 개수: \(self.sessions.count)")
            for s in self.sessions {
                print("  → \(s.date?.description ?? "nil"): \(s.safe_score)")
            }
        }
    }
}
