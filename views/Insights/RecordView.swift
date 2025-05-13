import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct RecordView: View {
    @State private var records: [String] = []
    @State private var isLoading = true

    var body: some View {
        VStack {
            Text("📜 Detection History")
                .font(.title2)
                .bold()
                .padding(.top)

            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if records.isEmpty {
                Spacer()
                Text("No detection records found.")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(records, id: \.self) { record in
                    Text(record)
                        .font(.body)
                        .padding(.vertical, 4)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .onAppear(perform: loadHistory)
    }

    func loadHistory() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).collection("history")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                isLoading = false
                if let documents = snapshot?.documents {
                    records = documents.map { doc in
                        let status = doc["status"] as? String ?? "Unknown"
                        let timestamp = doc["timestamp"] as? Timestamp ?? Timestamp()
                        let dateStr = DateFormatter.localizedString(
                            from: timestamp.dateValue(),
                            dateStyle: .short,
                            timeStyle: .short
                        )
                        return "[\(dateStr)] - \(status)"
                    }
                }
            }
    }
}

