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
            .chartPlotStyle { $0.padding(.vertical, 20) }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 7 * 86_400.0)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
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
