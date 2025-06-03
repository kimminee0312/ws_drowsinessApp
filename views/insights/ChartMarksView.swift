import SwiftUI
import Charts

struct ChartMarksView: ChartContent {
    let day: DailySummary
    let isSelected: Bool
    
    var body: some ChartContent {
        LineMark(
            x: .value("날짜", day.date),
            y: .value("점수", day.safeAvg)
        )
        .foregroundStyle(.blue)
        .lineStyle(.init(lineWidth: 2))
        
        PointMark(
            x: .value("날짜", day.date),
            y: .value("점수", day.safeAvg)
        )
        .foregroundStyle(isSelected ? .red : .blue)
        .symbolSize(isSelected ? 44 : 28)
        
        if isSelected {
            PointMark(
                x: .value("날짜", day.date),
                y: .value("점수", day.safeAvg)
            )
            .annotation(position: .top) {
                VStack(spacing: 2) {
                    Text(day.date, format: .dateTime.day())
                        .font(.caption2).bold()
                    Text(String(format: "%.0f", day.safeAvg))
                        .font(.caption2)
                }
                .padding(4)
                .background(.white.opacity(0.9))
                .cornerRadius(4)
            }
        }
    }
}
