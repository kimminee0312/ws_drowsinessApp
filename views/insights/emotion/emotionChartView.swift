import SwiftUI
import Charts

struct EmotionChartView: View {
    let summaries: [EmotionSummary]
    @Binding var selected: EmotionSummary?
    let axisColor: Color

    var body: some View {
        Chart {
            ForEach(summaries) { summary in
                LineMark(
                    x: .value("날짜", summary.date),
                    y: .value("Emotion Score", summary.emotionScore)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.blue)
                .symbol(.circle)
                .symbolSize(50)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day(.defaultDigits))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                if let plotFrame = proxy.plotFrame {
                                    let xPos = value.location.x - geo[plotFrame].origin.x
                                    if let date: Date = proxy.value(atX: xPos) {
                                        // 가장 가까운 date로 summary 선택
                                        if let nearest = summaries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                                            selected = nearest
                                        }
                                    }
                                }
                            }
                    )
            }
        }
    }
}
