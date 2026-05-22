# Drowsy Detection iOS Application

> 전공 학점 인정 프로젝트 (2025.01 – 2025.06) · 성적 A+ · iOS 앱 개발 담당

ROS 2 기반 졸음 감지 시스템과 **Firebase로 연동되어 운전자에게 실시간 알림을 전달**하는 iOS 어플리케이션입니다.


<img width="988" height="377" alt="image" src="https://github.com/user-attachments/assets/58c1f77e-c2d5-4d73-a4ac-ee6a467e273a" />
<img width="1742" height="677" alt="image" src="https://github.com/user-attachments/assets/0c8ac18e-351f-4514-b4e6-e7c405b3da25" />
<img width="1754" height="669" alt="image" src="https://github.com/user-attachments/assets/0989b6ab-2f1b-4644-95d2-c951585418ed" />
<img width="1737" height="660" alt="image" src="https://github.com/user-attachments/assets/19a0a425-4f74-41cf-b5c3-2b5649226ff9" />
<img width="1049" height="663" alt="image" src="https://github.com/user-attachments/assets/27219870-527d-4f3b-b511-6701cd1c098b" />


---

## 프로젝트 목적

- 졸음 감지 결과를 **운전자가 즉시 인지**할 수 있는 모바일 알림 시스템
- 실시간 상태 모니터링 + **졸음 통계 시각화**
- Firebase Firestore를 통한 ROS 2 시스템과의 **무선 연동**

---

## 사용 기술 스택

| 영역 | 기술 |
|---|---|
| **언어** | Swift (100%) |
| **플랫폼** | iOS |
| **백엔드 연동** | Firebase Firestore, Firebase Cloud Messaging |
| **시작/종료 제어** | HTTP POST → FastAPI 서버 |

---

## 디렉토리 구조

```
ws_drowsinessApp/
├── DrowsinessApp.xcodeproj/     # Xcode 프로젝트 설정
├── DrowsinessApp/                # 앱 메인 소스 코드
├── views/                        # 화면(View) 컴포넌트
├── sound/                        # 알림 사운드 리소스
└── .gitignore
```

### 디렉토리·파일 역할

| 항목 | 역할 |
|---|---|
| **`DrowsinessApp.xcodeproj/`** | Xcode 프로젝트 파일. 빌드 설정·타깃·스킴 정의 |
| **`DrowsinessApp/`** | 앱 메인 소스 코드. 진입점·모델·서비스·Firebase 연동 로직 포함 |
| **`views/`** | SwiftUI 또는 UIKit 화면 컴포넌트. 메인 화면·통계 화면·설정 화면 등 |
| **`sound/`** | 졸음 알림 사운드 리소스 파일 |
| **`.gitignore`** | Git 추적 제외 파일 (DerivedData·빌드 산출물 등) |

<img width="509" height="288" alt="image" src="https://github.com/user-attachments/assets/3e3e0e74-4789-4bbe-8caf-7e57ce113d0c" />
