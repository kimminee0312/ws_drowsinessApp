import SwiftUI
import Charts

struct DailyChart: View {
    let summaries: [DailySummary]
    @Binding var selected: DailySummary?
    let axisColor: Color

    // 최근 7일치 데이터만
    private var recentSummaries: [DailySummary] {
        if summaries.count > 10 {
            return Array(summaries.suffix(10))
        } else {
            return summaries
        }
    }

    var body: some View {
        Chart {
            ForEach(Array(recentSummaries.enumerated()), id: \.element.id) { idx, day in
                // ─── 선 + 점 ───
                LineMark(
                    x: .value("Index", idx),
                    y: .value("Score", day.safeAvg)
                )
                .foregroundStyle(.blue)
                .lineStyle(.init(lineWidth: 2))

                PointMark(
                    x: .value("Index", idx),
                    y: .value("Score", day.safeAvg)
                )
                .foregroundStyle(day.id == selected?.id ? .red : .blue)
                .symbolSize(day.id == selected?.id ? 44 : 28)

                // ─── 선택된 날 강조 ───
                if day.id == selected?.id {
                    PointMark(
                        x: .value("Index", idx),
                        y: .value("Score", day.safeAvg)
                    )
                    .annotation(position: .bottom) {
                        Text(String(format: "%.0f", day.safeAvg))
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(.white.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        // ─── Y축을 왼쪽으로 ───
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
                    .foregroundStyle(axisColor)
            }
        }
        
        // ─── 스케일 도메인 재설정 ───
        .chartYScale(domain: 0...100)
        .chartXScale(domain: 0...Double(max(0, recentSummaries.count - 1)))
        .chartXAxis {
            AxisMarks(values: Array(recentSummaries.indices).map(Double.init)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let idx = value.as(Double.self).map(Int.init),
                       recentSummaries.indices.contains(idx) {
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
                    .onTapGesture { location in
                        // 1) plotAreaFrame 기준 좌표로 변환
                        let xPos = location.x - geo[proxy.plotAreaFrame].origin.x
                        // 2) xPos → domain 좌표(Double)
                        if let xValue: Double = proxy.value(atX: xPos) {
                            // 3) 가장 가까운 인덱스로 반올림
                            let idx = Int(xValue.rounded())
                            // 4) 안전하게 바운딩 후 선택
                            if recentSummaries.indices.contains(idx) {
                                selected = recentSummaries[idx]
                            }
                        }
                    }
            }        }
        .frame(height: 220)
    }
}
