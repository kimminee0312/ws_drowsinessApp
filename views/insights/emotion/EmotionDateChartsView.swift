import SwiftUI
struct EmotionDateChartsView: View {
    @EnvironmentObject var emotionVM: EmotionSessionViewModel
    @Binding var selectedSummary: DailyEmotionSummary?   // ← @State → @Binding

    private let axisColor = Color(.darkGray)
    private let plotBg     = Color.white
    private let hPad: CGFloat = 16
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack() {
                    Text("내 감정 점수")
                        .font(.headline)
                        .foregroundColor(axisColor)
                        .padding(.top, 10)
                    
                    EmotionGaugeView(
                        avgEmotionScore: selectedSummary?.avgEmotionScore ?? 0
                    )
                    .frame(width: 140)
                    .padding(.top, 15)
                }
                VStack() {
                    if let summary = selectedSummary {
                        EmotionImageView(
                            emotionSummary: summary.dominantEmotion
                        )
                        .scaledToFit()
                        .frame(maxWidth: 140, maxHeight: 140)
                        .cornerRadius(12)
                        
                        Text("[ 오늘의 감정 ]")
                            .font(.caption2)
                            .foregroundColor(axisColor)
                    } else {
                        Text("날짜를 탭해주세요")
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                }
            }
            .padding(.horizontal, hPad)
            
            Text("내 감정 점수")
                .font(.headline)
                .foregroundColor(axisColor)
                .padding(.top, 10)
                .padding(.leading, hPad)
            
            // 그래프
            EmotionChartView(
                summaries: emotionVM.dailyEmotionSummaries,
                selected: $selectedSummary,
                axisColor: axisColor
            )
            .frame(height: 250)
            .background(plotBg)
            .padding(.horizontal, hPad)
            .cornerRadius(8)
            .padding(.top, 5)
            .onAppear {
                emotionVM.fetchAllSessions()
            }
        }
        .padding(.vertical, 5)
        .background(.white)
    }
}
