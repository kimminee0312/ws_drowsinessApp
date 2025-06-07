import SwiftUI

/// 0–100 피로도(높을수록 피로) ▶︎ 가로 막대 + 옆에 숫자
struct FatigueBarView: View {
    let score: Double          // 0 – 100

    // 막대 색상(단일 톤)
    private var barColor: Color { Color(.darkGray) }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // ▷ 막대 부분: GeometryReader 안 쓰고, 직접 비율 계산
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 14)

                Capsule()
                    .fill(barColor)
                    .frame(width: (CGFloat(score) / 100) * barWidth,
                           height: 14)
                    .animation(.easeOut(duration: 0.4), value: score)
            }
            .frame(width: barWidth, height: 14)

            .padding(20)
            
            // ▷ 막대 바로 옆 숫자
            Text(String(format: "%.0f", score))
                .font(.caption)
                .bold()
                .foregroundColor(Color(.darkGray))
        }
        // HStack 전체 높이를 막대 높이에 맞춰 고정
        .frame(height: 14)
    }

    // 원하는 막대 최대 폭을 여기에 설정하세요
    private let barWidth: CGFloat = 140
}
