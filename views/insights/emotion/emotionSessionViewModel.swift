import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class EmotionSessionViewModel: ObservableObject {
    @Published var uid: String = ""
    @Published var emotionSummaries: [EmotionSummary] = []
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init(uid: String) {
        self.uid = uid
        if !uid.isEmpty {
            fetchEmotionSummaries()
        }
    }
    
    func fetchEmotionSummaries() {
        guard !uid.isEmpty else { return }
        
        let col = db.collection("users").document(uid).collection("EmotionData")
        col.getDocuments { [weak self] (snap: QuerySnapshot?, err: Error?) in
            guard let self else { return }
            if let err {
                self.errorMessage = err.localizedDescription
                return
            }
            
            let list = snap?.documents.compactMap { doc -> EmotionSummary? in
                let data = doc.data() 

                guard let score = data["emotion score"] as? Double,
                      let summary = data["emotion summary"] as? String else { return nil }
                
                let dateStr = doc.documentID
                guard let date = Self.dayF.date(from: dateStr) else { return nil }
                
                return EmotionSummary(
                    id: doc.documentID,
                    date: date,
                    emotionScore: score,
                    emotionSummary: summary
                )
            } ?? []
            
            self.emotionSummaries = list.sorted { $0.date < $1.date }
        }
    }
    
    private static let dayF: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
