import SwiftUI

struct BlinkYawnStatsViewDaily: View {
    let day: DailySummary
    
    private let labelColor = Color(.darkGray)
    private let valueColor = Color(.darkGray)
    private let cardBg     = Color(.systemGray6)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row("평균 안전 점수",  String(format: "%.0f", day.safeAvg))
            row("눈 감김 합계",   "\(day.blinkTotal)")
            row("하품 합계",     "\(day.yawnTotal)")
            row("평균 하품시간", String(format: "%.1f 초", day.yawnAvgDur))
            if let p = day.peakTime { row("피크 졸음", p) }
        }
        .padding()
        .background(cardBg)
        .cornerRadius(12)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(labelColor)
            Spacer()
            Text(value).bold().foregroundColor(valueColor)
        }
    }
}
