import SwiftUI
import Charts

struct EmotionChartView: View {
    let summaries: [DailyEmotionSummary]
    @Binding var selected: DailyEmotionSummary?
    let axisColor: Color

    // 최근 7일치 데이터만
    private var recentSummaries: [DailyEmotionSummary] {
        if summaries.count > 10 {
            return Array(summaries.suffix(10))
        } else {
            return summaries
        }
    }

    var body: some View {
        Chart {
            ForEach(Array(recentSummaries.enumerated()), id: \.element.id) { idx, day in
                LineMark(
                    x: .value("Index", idx),
                    y: .value("Score", day.avgEmotionScore)
                )
                .foregroundStyle(.blue)
                .lineStyle(.init(lineWidth: 2))

                PointMark(
                    x: .value("Index", idx),
                    y: .value("Score", day.avgEmotionScore)
                )
                .foregroundStyle(day.id == selected?.id ? .red : .blue)
                .symbolSize(day.id == selected?.id ? 44 : 28)

                if day.id == selected?.id {
                    PointMark(
                        x: .value("Index", idx),
                        y: .value("Score", day.avgEmotionScore)
                    )
                    .annotation(position: .bottom) {
                        Text(String(format: "%.0f", day.avgEmotionScore))
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(.white.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel().foregroundStyle(axisColor)
            }
        }
        .chartYScale(domain: 0...100)
        .chartXScale(domain: 0...Double(max(0, recentSummaries.count - 1)))
        .chartXAxis {
            AxisMarks(values: Array(recentSummaries.indices).map(Double.init)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let idx = value.as(Double.self).map(Int.init), recentSummaries.indices.contains(idx) {
                        Text(recentSummaries[idx].date, format: .dateTime.day())
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { loc in
                                let xPos = loc.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let xValue: Double = proxy.value(atX: xPos) {
                                    let idx = Int(xValue.rounded())
                                    if recentSummaries.indices.contains(idx) {
                                        selected = recentSummaries[idx]
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 220)
    }
}
