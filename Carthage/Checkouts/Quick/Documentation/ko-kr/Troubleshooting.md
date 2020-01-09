# 일반적인 설치 이슈들

다음은 framework를 사용할 때 나타나는 일반적인 문제에 대한 해결책입니다.

## No such module 'Quick'

- 이미 `pod install`을 실행한 경우, Xcode workspace를 닫았다가 다시 열어주세요. 그래도 문제가 해결되지 않는다면, 다음을 계속하세요.
- _폴더 전체_ `~/Library/Developer/Xcode/DerivedData`를 삭제합니다. 여기에는 `ModuleCache` 가 포함됩니다.
- Scheme 관리 창에서 scheme을 활성화한 후, `Quick`, `Nimble` 그리고 `Pods-ProjectNameTests` 타깃을 명시적으로 빌드 (`Cmd+B`) 합니다.

