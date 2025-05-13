import SwiftUI

struct InsightsView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Insights")
                    .font(.largeTitle)
                    .foregroundColor(Color(.darkGray))
                    .bold()
                    .padding(.top)

                // 요약 카드
                HStack(spacing: 16) {
                    SummaryCard(title: "Total Drowsy", value: "18", icon: "zzz")
                    SummaryCard(title: "Peak Time", value: "14~16h", icon: "clock")
                }

                // 그래프 뷰 placeholder
                Text("📊 Weekly Chart")
                    .font(.headline)
                    .foregroundColor(Color(.darkGray))
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 200)
                    .overlay(Text("Chart Coming Soon"))
                    .cornerRadius(10)

                // 기록 리스트로 이동 버튼
                NavigationLink(destination: RecordView()) {
                    Text("View Detailed Records")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(icon)
                    .font(.title2)
                Spacer()
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .bold()
        }
        .padding()
        .frame(width: 150, height: 100)
        .background(Color(UIColor.lightGray).opacity(0.2))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
