# Objective-C에서 Quick 사용하기

Quick은 Swift와 Objective-C 모두에서 똑같이 잘 작동합니다.

그러나 Objective-C에서 Quick을 사용할 때 유의해야 할 두 가지를 아래에서 설명합니다. 

## Optional 약식 구문

Objective-C 파일에서 Quick을 가져오면,  `it`과 `itShouldBehaveLike` 같은 매크로와 `context()` 와 `describe()` 같은 함수들이 정의됩니다.

만약 테스트 중인 프로젝트에서 이러한 이름을 가진 심볼을 정의한다면, 혼란스러운 빌드 오류를 마주할 수 있습니다. 이럴 때에는, 네임스페이스 충돌을 Quick의 Optional "약식" 구문을 해제함으로 피할 수 있습니다:

```objc
#define QUICK_DISABLE_SHORT_SYNTAX 1

@import Quick;

QuickSpecBegin(DolphinSpec)
// ...
QuickSpecEnd
```

`QUICK_DISABLE_SHORT_SYNTAX` 매크로를 Quick을 헤더에 임포트 하기 전에 정의해야 합니다.

또한, test target의 build configuration에서 매크로를 정의할 수 있습니다:

![](http://d.twobitlabs.com/VFEamhvixX.png)

## 테스트 타겟에는 적어도 하나의 Swift 파일이 포함되어야 합니다

Swift stdlib은 테스트 대상에 연결되지 않으므로, test target에 *적어도 하나의* Swift 파일이 포함되어 있지 않으면 Quick이 제대로 실행되지 않습니다.

적어도 하나의 Swift 파일이 없으면, 테스트는 다음 오류로 인해 조기 종료될 것입니다:

```
*** Test session exited(82) without checking in. Executable cannot be
loaded for some other reason, such as a problem with a library it
depends on or a code signature/entitlements mismatch.
```

문제를 해결하기 위해, `SwiftSpec.swift` 라는 빈 테스트 파일을 test target에 추가하세요:

```swift
// SwiftSpec.swift

import Quick
```

> 이 이슈에 대한 자세한 내용은 https://github.com/Quick/Quick/issues/164를 참조하세요.
