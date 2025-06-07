import SwiftUI
import Charts

struct DailyChart: View {
    let summaries: [DailySummary]
    @Binding var selected: DailySummary?
    let axisColor: Color
    
    // ✦ 핵심: Chart를 별도 변수로 만든 뒤 AnyView로 래핑
    private var wrappedChart: AnyView {
        // ① 가장 안쪽 핵심 Chart
        let core = Chart {
            ForEach(summaries.indices, id: \.self) { idx in
                let day      = summaries[idx]
                let isSelect = day.id == selected?.id
                ChartMarksView(day: day, isSelected: isSelect)
            }
        }
        // ② modifier 들은 core 에 차례로 적용
        let decorated = core
            .chartYScale(domain: 0...100)
            .chartPlotStyle { plotArea in          // ② 하단 패딩 최소화
                plotArea.padding(.top, 20)         // 상단만 20pt
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 7 * 86_400.0)
            // summaries 에 있는 날짜만 전달 → 점이 있는 날만 라벨
            .chartXAxis {
                AxisMarks(values: summaries.map(\.date)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisValueLabel().foregroundStyle(axisColor)
                }
            }
            .chartOverlay { proxy in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if let d: Date = proxy.value(atX: value.location.x),
                                   let hit = summaries.first(where: {
                                       Calendar.current.isDate($0.date,
                                                               equalTo: d,
                                                               toGranularity: .day)
                                   }) {
                                    selected = hit
                                }
                            }
                    )
            }
        
        // ③ AnyView 로 타입 지우기 → 타입-체크 종료
        return AnyView(decorated)
    }
    
    // body 는 이미 타입 결정된 wrappedChart 만 반환
    var body: some View { wrappedChart }
}

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
            .annotation(position: .bottom) {
                VStack(spacing: 2) {
                    Text(String(format: "%.0f", day.safeAvg))
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .padding(4)
                .background(.white.opacity(0.9))
                .cornerRadius(4)
            }
        }
    }
}
