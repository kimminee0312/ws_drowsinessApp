import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var vm: SessionViewModel
    @EnvironmentObject var emotionVM: EmotionSessionViewModel
    @State private var selDay: DailySummary? = nil
    @State private var selectedTab = 0
    
    let tabs = ["Drowsy History", "Emotion History"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ------------------상단 탭바 커스텀---------------------
                HStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            Text(tabs[index])
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                                .foregroundColor(selectedTab == index ? .blue : .gray)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(Divider(), alignment: .bottom)
                
                // --------------------선택된 탭에 따른 데이터 통계---------------------
                Group {
                    if selectedTab == 0 {
                        if vm.dailySummaries.isEmpty {
                            ProgressView("데이터 불러오는 중…")
                        } else {
                            VStack(spacing: 0) {
                                Spacer()
                                Text("Drowsy Insights")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Color(.darkGray)) // 어두운 회색
                                
                                DateChartView(
                                    selectedDate: selDay?.date,
                                    safeScore:    selDay?.safeAvg ?? 0,
                                    fatigueScore: selDay?.fatigueAvg ?? 0,
                                    summaries:    vm.dailySummaries,
                                    selectedSummary: $selDay
                                )
                                .padding(.top, 16)
                                
                                Divider().padding(.vertical, 8)
                                
                                // ── ⓒ 상세 뷰 or 안내문 ──
                                if let d = selDay {
                                    BlinkYawnStatsViewDaily(day: d)
                                        .padding(.bottom, 16)
                                } else {
                                    Text("날짜를 탭해주세요")
                                        .foregroundColor(.gray)
                                        .padding(.top, 20)
                                }
                                
                                Spacer()
                            }
                        }
                        
                    } else if selectedTab == 1 {
                        VStack(Spacing: 0){
                            Spacer()
                            Text("Emotion Insights")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color(.darkGray)) // 어두운 회색
                            // ---------------감정 인식 통계 뷰-------------------
                            EmotionDateChartsView()
                            .padding(.top, 16)

                        }
                    }
                }
                .background(Color.white)
                .navigationBarHidden(true)
            }
            .background(Color.white.ignoresSafeArea())
        }
    }
}

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

struct EmotionDateChartsView: View {
    @EnvironmentObject var emotionVM: EmotionSessionViewModel
    @State private var selectedSummary: EmotionSummary? = nil

    private let axisColor = Color(.darkGray)
    private let hPad: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 타이틀
            Text("내 감정 점수")
                .font(.headline)
                .foregroundColor(axisColor)

            // 그래프
            EmotionChartView(
                summaries: emotionVM.emotionSummaries,
                selected: $selectedSummary,
                axisColor: axisColor
            )
            .frame(height: 250)
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, hPad)
            .padding(.top, 12)

            Divider().padding(.vertical, 8)

            // 오늘의 감정
            VStack(alignment: .leading, spacing: 8) {
                Text("오늘의 감정")
                    .font(.headline)
                    .foregroundColor(axisColor)

                if let summary = selectedSummary {
                    EmotionImageView(emotionSummary: summary.emotionSummary)
                        .scaledToFit()
                        .frame(maxWidth: 140, maxHeight: 140)
                        .cornerRadius(12)
                } else {
                    Text("날짜를 탭해주세요")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, hPad)

            Spacer()
        }
        .onAppear {
            emotionVM.fetchEmotionSummaries()
        }
    }
}

