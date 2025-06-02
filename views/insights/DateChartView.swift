import SwiftUI
import Charts

struct DateChartView: View {
    let sessions: [SessionData]
    @Binding var selectedSession: SessionData?

    // date가 nil이 아닌 세션만 튜플로 묶어서 반환
    private var chartData: [(session: SessionData, date: Date)] {
        sessions.compactMap { session in
            guard let d = session.date else { return nil }
            return (session: session, date: d)
        }
    }

    private var dayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }

    private let axisColor = Color(UIColor.darkGray)
    private let plotBgColor = Color.white

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("일자별 안전 운전 점수")
                .font(.headline)
                .foregroundColor(axisColor)
                .padding(.leading, 4)

            Chart(chartData, id: \.session.id) { pair in
                let session = pair.session
                let date = pair.date
                let dayStr = dayFormatter.string(from: date)

                // 꺾은선
                LineMark(
                    x: .value("날짜", dayStr),
                    y: .value("점수", session.safe_score)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))

                // 데이터 점
                PointMark(
                    x: .value("날짜", dayStr),
                    y: .value("점수", session.safe_score)
                )
                .foregroundStyle(.blue)
                .symbolSize(40)

                // 선택된 세션일 때 숫자 annotation
                if selectedSession?.id == session.id {
                    PointMark(
                        x: .value("날짜", dayStr),
                        y: .value("점수", session.safe_score)
                    )
                    .annotation(position: .top) {
                        Text("\(session.safe_score)")
                            .font(.caption)
                            .foregroundColor(axisColor.opacity(0.6))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisValueLabel().foregroundStyle(axisColor)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: chartData.count)) { _ in
                    AxisGridLine()
                    AxisValueLabel().foregroundStyle(axisColor)
                }
            }
            .frame(height: 200)
            .background(plotBgColor)
            .cornerRadius(8)
            .padding(.horizontal, 4)

            // ─────────────────────────────────────────────
            // ⚠︎ Chart 전체에 Overlay를 씌워서 TapGesture를 받도록 합니다.
            .chartOverlay { proxy in
                // `GeometryReader`를 이용해 터치 위치(x좌표)를 측정
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)         // 투명 레이어
                        .contentShape(Rectangle())  // 전체 영역을 tap 대상으로 만듦
                        .onTapGesture { location in
                            // location: 차트 뷰 좌측 상단에서의 탭 좌표(x:CGFloat, y:CGFloat)
                            let xPosition = location.x
                            // 차트의 X축 값(여기서는 “dayStr” 였기 때문에 문자열)에 매핑
                            if let dayValue: String = proxy.value(atX: xPosition) {
                                // dayValue는 “1”, “2” 같은 “일(day)” 문자열
                                // chartData에 해당 dayValue를 찾아서 세션 선택
                                if let matched = chartData.first(where: {
                                    let d = $0.date
                                    return dayFormatter.string(from: d) == dayValue
                                }) {
                                    selectedSession = matched.session
                                }
                            }
                        }
                }
            }
            // ─────────────────────────────────────────────
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}
