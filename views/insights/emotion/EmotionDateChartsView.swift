import SwiftUI
struct EmotionDateChartsView: View {
    @EnvironmentObject var emotionVM: EmotionSessionViewModel
    @State private var selectedSummary: EmotionSummary? = nil
    
    private let axisColor = Color(.darkGray)
    private let hPad: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack() {
                        Text("내 감정 점수")
                            .font(.headline)
                            .foregroundColor(axisColor)
                            .padding(.top, 10)
                        
                        EmotionGaugeView(score: selectedSummary?.emotionScore ?? 0)
                            .frame(width: 140)
                            .padding(.top, 15)
                    }
                    VStack() {
                        if let summary = selectedSummary {
                            EmotionImageView(emotionSummary: summary.emotionSummary)
                                .scaledToFit()
                                .frame(maxWidth: 140, maxHeight: 140)
                                .cornerRadius(12)
                        } else {
                            Text("날짜를 탭해주세요")
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                        }
                        
                        Text("오늘의 감정: ")
                            .font(.caption2)
                            .foregroundColor(axisColor)
                    }
                }
                .padding(.horizontal, hPad)
            }
            .padding(.horizontal, hPad)
            
            Text("내 감정 점수")
                .font(.headline)
                .foregroundColor(axisColor)
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            // 그래프
            EmotionChartView(
                summaries: emotionVM.emotionSummaries,   // 사용 OK
                selected: $selectedSummary,
                axisColor: axisColor
            )
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.top, 12)
        }
        .padding(.horizontal, hPad)
        Divider().padding(.vertical, 8)
        .onAppear {
            emotionVM.fetchAllSessions()
        }
    }
}
