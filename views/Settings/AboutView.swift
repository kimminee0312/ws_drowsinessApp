import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()
                
                Text("Technology Implementation")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color(.darkGray)) // 어두운 회색
                
                // 앱 만든 사람
                VStack(spacing: 8) {
                    Text("App Developer")
                        .font(.caption)
                        .foregroundColor(Color(.darkGray))
                    Text("김민이")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                }
                .padding(.top)
                // 시스템 알고리즘 만든 사람
                VStack(spacing: 8) {
                    Text("System Developer")
                        .font(.caption)
                        .foregroundColor(Color(.darkGray))
                    Text("김민이, 김예지")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                }
                
                Divider()
                
                // 사용 알고리즘
                VStack(alignment: .leading, spacing: 8) {
                    Text("기술 구현")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Group {
                        Text("얼굴 인식 및 식별")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 4)
                        
                        BulletPoint(text: "Mediapipe 기반 얼굴 인식 및 얼굴 영역 추출")
                        BulletPoint(text: "FaceNet 기반 얼굴 embedding 생성 및 사용자 식별 (Firebase Firestore 기반 얼굴 로그인 기능 포함)")
                    }
                    Group {
                        Text("감정 인식 알고리즘")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 4)
                        
                        BulletPoint(text: "AIHub 한국인 감정인식용 복합 영상 데이터셋 학습 기반 감정 인식 알고리즘 개발")
                    }
                    Group {
                        Text("졸음 인식 알고리즘")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 4)
                        
                        BulletPoint(text: "dlib 68-point facial landmark detector 기반 상태 전이 로직 구현")
                        BulletPoint(text: "OpenCV 기반 하품, 눈 감김, 고개 끄덕임 감지 및 실시간 졸음 상태 분석 및 인식 알고리즘 개발")
                        BulletPoint(text: "사용자별 Custom Threshold 로직 구현 (Calibration 단계 후 Threshold 설정)")
                        BulletPoint(text: "알고리즘 성능 평가  실험 설계 및 F1-score 기반 분석 수행")
                    }
                    Group {
                        Text("앱 및 시스템 통신 개발")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 4)
                        
                        BulletPoint(text: "iOS (SwiftUI 기반) 앱 개발 및 사용자 상태 업데이트 기능 구현")
                        BulletPoint(text: "Firebase Authentication / Firestore 연동 및 사용자별 세션 기록 자동 저장 구조 설계 및 구현")
                        BulletPoint(text: "iOS (SwiftUI 기반) ⇄ FastAPI 서버 ⇄ ROS Service 서버 ⇄ ROS 기능 노드 (camera 입력 기반) 통신 구조 설계 및 구현")
                    }
                }
                .padding()
                .background(Color(.gray.opacity(0.1)))
                .cornerRadius(12)
                
                Divider()
                
                // 통신 방법
                VStack(alignment: .leading, spacing: 8) {
                    Text("사용 기술 출처")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("""
                    - 얼굴 감지 : Mediapipe Face Detection / Face Mesh (Google Research)
                    - 얼굴 인식 및 식별 : Florian Schroff, Dmitry Kalenichenko, James Philbin, "FaceNet: A Unified Embedding for Face Recognition and Clustering", 2015
                    - AIHub 한국인 감정인식용 복합 영상 데이터셋  
                      (https://www.aihub.or.kr/aihubdata/data/view.do?dataSetSn=82)
                    - 얼굴 특징점 검출 : Davis E. King, "dlib C++ Library" (http://dlib.net/)
                    """)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.gray.opacity(0.1)))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BulletPoint: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.blue)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
