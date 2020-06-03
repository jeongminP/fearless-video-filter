# ios-horror-filter
2020 네이버 핵데이 - 공포영화 필터링 iOS

## [About]
공포영화의 무서운 장면이 보기 힘든 사람들을 위해, 그러한 장면들이 나오는 구간을 api로 받아 해당 구간들에 블러효과를 입힘으로써 덜 무서운 시청 경험을 제공합니다.

## [Feature]
- Request video information from server
- Prefetch video informations when scrolling

- Implement Custom Player ViewController
- Implement Playback Controls (Resume video automatically)

- Apply blur filter on video asset

## [Get Started]
1. Clone our project

`git clone https://github.com/jeongminP/fearless-video-filter.git`

2. Need CocoaPods install

`pod install`

## [Preview]
| 메인화면                    | 재생화면(portrait)                              | 재생화면(landscape)                              |
|:------------------------------:|:---------------------------------:|:---------------------------------:|
|![KakaoTalk_Photo_2020-06-03-13-36-43](https://user-images.githubusercontent.com/24884220/83596327-530d8700-a59f-11ea-9567-a43664ea8ac0.png)|![KakaoTalk_Photo_2020-06-03-13-25-48](https://user-images.githubusercontent.com/24884220/83596237-1d689e00-a59f-11ea-8178-e0f04c826e7f.png)|![KakaoTalk_Photo_2020-06-03-13-25-42](https://user-images.githubusercontent.com/24884220/83596221-16419000-a59f-11ea-97f7-743e63a7d30e.png)|


## [Develop Environment]
- iOS Deployment Target : iOS 11.0
- CocoaPods Version : 1.9.1

## [Library]
- Alamofire
- SDWebImage
- SnapKit
- FLEX
