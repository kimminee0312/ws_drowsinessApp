//선택된 세션 하나만 받아와 정리
//날짜, 안전점수, 피로점수, 피크 졸음 시간, 눈 가김 횟수, 하품 횟수, 평균 하품 시간
import SwiftUI

struct BlinkYawnStatsView: View {
    let session: SessionData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("날짜:")
                    .foregroundColor(Color(UIColor.darkGray))
                if let date = session.date {
                    Text("\(date, formatter: dateFormatter)")
                        .foregroundColor(Color(UIColor.darkGray))
                }
                Spacer()
            }

            HStack {
                Text("안전 점수: \(session.safe_score)")
                    .foregroundColor(Color(UIColor.darkGray))
                Spacer()
                Text("피로 점수: \(session.fatigue_score)")
                    .foregroundColor(Color(UIColor.darkGray))
            }

            HStack {
                Text("눈 감김: \(session.drowsy_eye_closed)회")
                    .foregroundColor(Color(UIColor.darkGray))
                Spacer()
                Text("하품: \(session.yawns)회")
                    .foregroundColor(Color(UIColor.darkGray))
            }

            HStack {
                Text("평균 하품 시간: \(String(format: "%.1f", session.avg_yawn_duration))초")
                    .foregroundColor(Color(UIColor.darkGray))
                Spacer()
                Text("피크 졸음 시간: \(session.peak_drowsy_time)")
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
}
