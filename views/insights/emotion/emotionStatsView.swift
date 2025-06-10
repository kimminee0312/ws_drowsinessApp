import SwiftUI

struct EmotionStatsViewDaily: View {
    let day: DailyEmotionSummary
    
    private let labelColor = Color(.darkGray)
    private let valueColor = Color(.darkGray)
    private let cardBg     = Color(.systemGray6)
    
    //---------------날짜 포맷터---------------
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: day.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(formattedDate)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.bottom, 4)

            row("정상 상태 지속 시간", String(format: "%.1f 초", day.neutralDuration))
            row("긍정 상태 지속 시간", String(format: "%.1f 초", day.positiveDuration))
            row("부정 상태 지속 시간", String(format: "%.1f 초", day.negativeDuration))
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
