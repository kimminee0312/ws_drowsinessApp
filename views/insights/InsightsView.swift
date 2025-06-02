import SwiftUI
import FirebaseAuth

struct InsightsView: View {
    // 로그인된 사용자의 UID
    @State private var uid: String = Auth.auth().currentUser?.uid ?? ""

    // ViewModel
    @StateObject private var viewModel: SessionViewModel

    // 탭된 세션
    @State private var selectedSession: SessionData? = nil

    init() {
        let currentUID = Auth.auth().currentUser?.uid ?? ""
        _viewModel = StateObject(wrappedValue: SessionViewModel(uid: currentUID))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ◈ 4-1: 날짜별 안전 점수 차트
                DateChartView(
                    sessions: viewModel.sessions,
                    selectedSession: $selectedSession
                )
                .padding(.top, 16)

                Divider().padding(.vertical, 8)

                // ◈ 4-2: 탭된 세션이 있으면 통계 뷰 보여주기
                if let sel = selectedSession {
                    BlinkYawnStatsView(session: sel)
                        .padding(.bottom, 16)
                } else {
                    Text("날짜를 탭해 주세요.")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }

                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("인사이트")
        }
    }
}
