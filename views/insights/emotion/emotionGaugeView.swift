import SwiftUI

/// 반원형 안전 점수 게이지 (0 – 100)
struct EmotionGaugeView: View {
    var score: Double            // 0 – 100
    var spanDeg: Double = 210   // ⬅︎ 원하는 각도(°)
    // 호의 총 길이를 비율로 환산
    private var spanRatio: Double { spanDeg / 360 }
    
    // "score%" 만큼 진행된 trim 끝점
    private var progressEnd: Double { spanRatio * max(0, min(score, 100)) / 100 }

    // 시작 위치를 위쪽 중앙으로 맞추기 위한 회전값
    private var rotation: Double {270 - spanDeg / 2}
    private var gaugeColor: Color {
        switch score {
        case 80...: return .blue
        case 60..<80: return .yellow
        default: return .red
        }
    }

    var body: some View {
        GeometryReader { geo in
            let line: CGFloat = 8
            ZStack {
                // 배경 호
                Circle()
                    .trim(from: 0, to: spanRatio)
                    .rotation(.degrees(rotation))
                    .stroke(.gray.opacity(0.25), style: .init(lineWidth: line, lineCap: .round))

                // 값 호
                Circle()
                    .trim(from: 0, to: progressEnd)        // 0 – 0.5 범위
                    .rotation(.degrees(rotation))
                    .stroke(gaugeColor, style: .init(lineWidth: line, lineCap: .round))
                    .animation(.easeOut(duration: 0.4), value: progressEnd)

                // 중앙 점수 숫자
                Text(String(format: "%.0f", score))
                    .font(.title3.bold())
                    .foregroundColor(gaugeColor)
                    .offset(y: 7)                // 반원 아래쪽 보정
            }
            .frame(width: geo.size.width,
                   height: geo.size.width / 2,
                   alignment: .top)
        }
        .aspectRatio(2, contentMode: .fit)        // 가로:세로 = 2:1
    }
}
