import SwiftUI

struct EmotionImageView: View {
    let emotionSummary: String
    
    var body: some View {
        let imageName: String
        switch emotionSummary.lowercased() {
        case "neutral": imageName = "App_1024"
        case "negative": imageName = "driver_face_angry_1024"
        case "positive": imageName = "driver_face_happy_1024"
        default: imageName = "App_1024"
        }
        
        return Image(imageName)
            .resizable()
            .scaledToFit()
    }
}
