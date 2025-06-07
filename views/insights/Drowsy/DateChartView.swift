import SwiftUI

struct DateChartView: View {
    let selectedDate: Date?
    let safeScore:    Double
    let fatigueScore: Double
    let summaries:    [DailySummary]
    @Binding var selectedSummary: DailySummary?
    
    // ───────── state for info alerts ─────────
    @State private var showSafeInfo  = false
    @State private var showChartInfo = false

    // ───────── style ─────────
    private let axisColor  = Color(.darkGray)
    private let plotBg     = Color.white
    private let hPad: CGFloat = 16      // ← 가로 패딩 한 곳에서 관리
    
    // 피크 시간을 “HH:mm”으로 포맷하기 위한 DateFormatter
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ───── 상단: “안전 운전 점수” + ⓘ 버튼 ─────
            HStack {
                Text("내 안전 운전 점수")
                    .font(.headline)
                    .foregroundColor(axisColor)
                Button { showSafeInfo = true } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, hPad)
            .alert("내 안전 운전 점수", isPresented: $showSafeInfo) {
                Button("닫기", role: .cancel) { }
            } message: {
                Text("눈 감김 지속 시간을 70점 만점으로 환산하고\n"
                   + "하품·피로 지표를 합산해 0-100 범위로 계산한 값입니다.")
            }
            // ───── 안전 게이지 + 피로도 박스 ─────
            HStack(alignment: .top, spacing: 20) {
                // 왼쪽: 반원형 안전 게이지
                SafetyGaugeView(score: safeScore)
                    .frame(width: 140)
                
                // 오른쪽: 피로 막대 + 피크 시각
                VStack(alignment: .leading, spacing: 8) {
                    Text("피로도")
                        .font(.headline)
            
                    FatigueBarView(score: fatigueScore)
                        .frame(width: 140)
                    
                    HStack(spacing: 8) {
                        Text("Peak Drowsy Time: ")
                            .font(.caption2)
                            .foregroundColor(axisColor)

                        if let selected = selectedSummary,
                           let rawDate = selected.peakFatigueTime {
                            // DateFormatter를 써서 “HH:mm” 형태로 출력
                            Text(DateChartView.timeFormatter.string(from: rawDate))
                                .font(.caption2)
                                .foregroundColor(.blue)
                        } else {
                            // 아직 선택된 요약이 없거나, 해당 요약에 피크 시간이 없으면 None 대체
                            Text("None")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 5)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, hPad)          // 좌·우 동일 여백
            
            // ───── 하단: “일자별 인식 통계” + ⓘ 버튼 ─────
            HStack {
                Text("일자별 인식 통계")
                    .font(.headline)
                    .foregroundColor(axisColor)
                Button { showChartInfo = true } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, hPad)
            .alert("일자별 인식 통계", isPresented: $showChartInfo) {
                Button("닫기", role: .cancel) { }
            } message: {
                Text("하루마다 눈 감김·하품·안전·피로 점수를 집계한 그래프입니다.\n"
                   + "점을 탭하면 해당 날짜의 상세 값을 볼 수 있습니다.")
            }
            
            // ───── 그래프 ─────
            DailyChart(
                summaries: summaries,
                selected: $selectedSummary,
                axisColor: axisColor
            )
            .frame(height: 250)
            .background(plotBg)
            .cornerRadius(8)
            .padding(.horizontal, hPad)
            .padding(.top, 12)
        }
        .padding(.vertical, 8)
        .background(.white)
    }
}
