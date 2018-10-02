# Xcode 프로젝트에 Test 설정하기

Xcode7에서는 Command Line Tool 프로젝트 유형을 제외하고 새 프로젝트를 만들면, 기본적으로 Unit test target이 포함됩니다. [Command Line Tool 프로젝트에 대한 특정 지시사항 보기](#Command-Line-Tool-프로젝트에서-테스트-타겟-설정하기). 단위 테스트를 작성하려면, 필수적으로 Unit test target에서 Main target 코드를 사용할 수 있어야 합니다. 

## Swift 코드를 Swift에서 테스트하기

Swift로 작성된 코드를 테스트하려면 다음 두 가지 작업을 수행해야 합니다.

1.  `.xcodeproj` 에서 "Defines Module"을 `YES`로 설정하십시오.

  * Xcode에서 하려면: 프로젝트를 선택하고, "Build Settings"의 "Packaging" 헤더에서,
    "Defines Module" 라인을 "Yes"로 선택하세요. 참고: "Packaging" 섹션을 보려면 Build Settings를 "Basic" 대신 "All"로 선택해야 합니다.

2.  `@testable import YourAppModuleName` 을 당신의 유닛테스트에 포함하세요. 그러면 `Public`과 `internal` (기본) 기호가 당신의 테스트에 표시될 것입니다. `private` 기호는 아직 사용할 수 없습니다.

```swift
// MyAppTests.swift

import XCTest
@testable import MyModule

class MyClassTests: XCTestCase {
  // ...
}
```

> Xcode Test Navigator의 Quick과의 통합에는 몇 가지 제약 사항이 있습니다. (open [issue](https://github.com/Quick/Quick/issues/219)). Quick 테스트는 실행될 때까지 내이게이터에 표시되지 않을 것이며, 반복 실행은 예측할 수 없는 방향으로 목록을 재설정하는 경향이 있으며, 테스트는 소스 코드 옆에 표시되지 않습니다.
> 레이더를 Apple에 제출하고, Apple 엔지니어에게 이 기능 요구를 홍보하기 위해 [rdar://26152293](http://openradar.appspot.com/radar?id=4974047628623872)을 언급하세요.

> 일부 개발자는 Swift 소스 파일을 test target으로 추가할 것을 권장합니다.
> 하지만 이는 [미묘하고, 오류를 진단하기 어려워지므로](https://github.com/Quick/Quick/issues/91), 권장 사항은 아닙니다.

## Objective-C 코드를 Swift에서 테스트하기

1. Bridging header를 Test target에 추가하세요.
2. Bridging header에서, 테스트 해야 할 코드가 있는 파일을 불러옵니다.

```objc
// MyAppTests-BridgingHeader.h

#import "MyClass.h"
```

이제 Swift 테스트 파일에서 `MyClass.h` 에 있는 코드를 사용할 수 있습니다.

## Swift 코드를 Objective-C에서 테스트하기

1. `@objc` 속성을 사용하여 Objective-C로 테스트하려는 Swift 클래스와 함수를 연결합니다.
2. 당신의 단위 테스트에서 모듈의 Swift 헤더들을 불러옵니다.

```objc
@import XCTest;
#import "MyModule-Swift.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

## Objective-C 에서 Objective-C 코드를 테스트하기

Test target에서 테스트하려는 코드가 정의된 파일을 불러옵니다.

```objc
// MyAppTests.m

@import XCTest;
#import "MyClass.h"

@interface MyClassTests: XCTestCase
// ...
@end
```

### Command Line Tool 프로젝트에서 테스트 타겟 설정하기

1. 프로젝트 창에서 대상을 프로젝트에 추가합니다.
2. "OS X Unit Testing Bundle"을 선택합니다.
3. 주요 타깃의 스키마를 편집합니다.
4. "Test" 를 선택하고, "Info" 머리말 아래 있는 "+"를 클릭한 뒤, 당신의 테스트 번들을 선택하세요.
