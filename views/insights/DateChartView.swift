import SwiftUI

struct DateChartView: View {
    let summaries: [DailySummary]
    @Binding var selectedSummary: DailySummary?
    
    private let axisColor  = Color(.darkGray)
    private let plotBg     = Color.white
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("일자별 안전 운전 점수")
                .font(.headline)
                .foregroundColor(axisColor)
                .padding(.leading, 4)
            
            DailyChart(summaries: summaries,
                       selected: $selectedSummary,
                       axisColor: axisColor)
                .frame(height: 220)
                .background(plotBg)
                .cornerRadius(8)
                .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
        .background(.white)
    }
}
