import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var vm: SessionViewModel
    @EnvironmentObject var emotionVM: EmotionSessionViewModel
    @State private var selDay: DailySummary? = nil
    @State private var selEmotionDay: DailyEmotionSummary? = nil
    @State private var selectedTab = 0
    
    let tabs = ["Drowsy Insights", "Emotion Insights"]
    
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
                if selectedTab == 0 {
                    if vm.dailySummaries.isEmpty {
                        ProgressView("데이터 불러오는 중…")
                    } else {
                        VStack(spacing: 0) {
                            Spacer()
                            Text("Drowsy Insights")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Color(.darkGray))
                            
                            DateChartView(
                                selectedDate: selDay?.date,
                                safeScore:    selDay?.safeAvg ?? 0,
                                fatigueScore: selDay?.fatigueAvg ?? 0,
                                summaries:    vm.dailySummaries,
                                selectedSummary: $selDay
                            )
                            .padding(.top, 16)
                            
                            Divider().padding(.vertical, 15)
                            
                            if let d = selDay {
                                BlinkYawnStatsViewDaily(day: d)
                                    .padding(.bottom, 10)
                            } else {
                                Text("날짜를 탭해주세요")
                                    .foregroundColor(.gray)
                                    .padding(.top, 20)
                            }
                            
                            Spacer()
                        }
                    }
                } else if selectedTab == 1 {
                    VStack(spacing: 0) {
                        Spacer()
                        Text("Emotion Insights")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color(.darkGray))
                        
                        EmotionDateChartsView(
                        selectedSummary: $selEmotionDay
                        )
                        .padding(.top, 13)
                        
                        Divider().padding(.vertical, 15)
                        
                        if let d = selEmotionDay {
                            EmotionStatsViewDaily(day: d)
                                .padding(.bottom, 10)
                        } else {
                            Text("날짜를 탭해주세요")
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }
                        Spacer()
                    }
                }
            }
            .background(Color.white) // 여기서 걸어주기 (VStack 전체에)
            .navigationBarHidden(true) // 여기서 전체 NavigationView 에 적용
        }
    }
}
