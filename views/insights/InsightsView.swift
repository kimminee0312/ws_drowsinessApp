// InsightsView.swift

import SwiftUI

struct InsightsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            
            Text("Insights")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.gray)
                .padding(.top, 30)
                .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGray6)) // 연한 회색 배경
        .ignoresSafeArea()
    }
}
