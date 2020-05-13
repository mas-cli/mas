# Quick 설치하기

>시작하기 전에, 어떤 버전의 Quick과 Nimble이 당신의 스위프트 버전에 잘 돌아가는지 [이곳](../../README.md#swift-version)에서 확인하세요.

Quick은 예제들과 예제 그룹을 정의하는 구문을 제공합니다. Nimble은 `expect(...).to`  라는 주장 구문을 제공합니다. 당신은 둘 중 하나, 또는 두 가지 모두를 테스트에 사용할 수 있습니다. 

여기에 Quick을 테스트에 연결할 수 있는 3가지 권장 방법이 있습니다:

1. [Git 서브 모듈](#Git-서브-모듈)
2. [CocoaPods](#cocoapods)
3. [Carthage](#carthage)
4. [Swift 패키지 매니저 (실험적 기능)](#swift-package-manager)

하나를 선택하고, 아래 지침을 따르세요. 이를 완료한다면, 당신의 test target의 파일에서 `import Quick`으로 Quick을 불러올 수 있어야 합니다.

## Git 서브 모듈

Git 서브 모듈을 사용하여 Quick과 Nimble을 링크하려면:

1. Quick 서브 모듈을 추가하세요.
2. `.xcworkspace` 가 프로젝트에 아직 없는 경우, 만드세요. ([방법은 이곳에](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_an_Existing_Project_to_a_Workspace.html))
3. `Quick.xcodeproj`를 프로젝트의 `.xcworkspace` 에 추가하세요.
4. `Nimble.xcodeproj` 또한 프로젝트의 `.xcworkspace` 에 추가하세요. `path/to/Quick/Externals/Nimble` 에 있습니다. Quick의 종속성에서 Nimble을 추가하면 (하위 모듈에서 바로 추가하는 것과 대조적으로), 당신이 사용하고 있는 Quick의 버전에 맞는 Nimble의 올바른 버전을 사용할 수 있게 됩니다.
5.  `Quick.framework`와 `Nimble.framework`를 test target 프로젝트의 "Link Binary with Libraries" build phase에 링크시키세요.

먼저, Git 서브 모듈을 위한 디렉터리가 없다면, 하나 만드세요.
`Vendor` 라는 이름의 디렉터리가 있다고 가정해보겠습니다.

**Step 1:** Quick과 Nimble을 Git 서브 모듈에서 다운로드 받으세요:

```sh
git submodule add git@github.com:Quick/Quick.git Vendor/Quick
git submodule add git@github.com:Quick/Nimble.git Vendor/Nimble
git submodule update --init --recursive
```

**Step 2:** 위에서 다운로드 한 `Quick.xcodeproj` 와 `Nimble.xcodeproj` 파일을 당신의  `.xcworkspace `에 추가하세요. 예를 들어, `Guanaco.xcworkspace`은 Quick과 Nimble을 사용하여 테스트하는 프로젝트의 워크스페이스 입니다.

![](http://f.cl.ly/items/2b2R0e1h09003u2f0Z3U/Screen%20Shot%202015-02-27%20at%202.19.37%20PM.png)

**Step 3:** `Quick.framework` 을 테스트 타겟의`Link Binary with Libraries` build phase에 링크시키세요. 두 개의 `Quick.frameworks` 가 보여야 합니다; macOS용과, iOS용.

![](http://cl.ly/image/2L0G0H1a173C/Screen%20Shot%202014-06-08%20at%204.27.48%20AM.png)

`Nimble.framework`도 위와 같이 추가하면 끝입니다!

**서브 모듈 업데이트하기:** Quick이나 Nimble 서브 모듈을 마지막 버전으로 업데이트하기 원한다면, Quick 디렉터리로 들어가서 master 레퍼지토리를 pull 하세요:

```sh
cd /path/to/your/project/Vendor/Quick
git checkout master
git pull --rebase origin master
```

당신의 Git 레퍼지토리는 서브 모듈의 변화를 트래킹할 것입니다. 당신은 Quick 서브 모듈을 업데이트했다는 것을 커밋하기 원할 것입니다.

```sh
cd /path/to/your/project
git commit -m "Updated Quick submodule"
```

**Quick 서브 모듈을 포함하는 레퍼지토리를 Clone 하기:** 다른 사람이 당신의 레퍼지토리를 clone 한 후에, 그들은 서브 모듈 또한 pull 해야 할 것입니다. 
`git submodule update` 명령어만 실행하면 됩니다:

```sh
git submodule update --init --recursive
```

Git 서브모듈에 대한 자세한 내용은  [여기](http://git-scm.com/book/en/Git-Tools-Submodules)를 참조하세요.

## CocoaPods

먼저, 코코아팟의 버전을 0.36.0 이상의 버전으로 업데이트하세요. Swift를 사용하여 코코아팟을 설치하는 데 필요합니다. 

그리고, Quick과 Nimble을 Podfile 에 추가하세요. 또한, ```use_frameworks!```은 코코아팟에서 Swift를 사용하기에 필요합니다:

```rb

# Podfile

use_frameworks!

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'MyTests' do
    testing_pods
end

target 'MyUITests' do
    testing_pods
end
```

마지막으로, 다운로드 후에 Quick과 Nimble을 테스트에 추가하세요:

```sh
pod install
```

## [Carthage](https://github.com/Carthage/Carthage)

Test target에 "Embedded Binaries" 섹션이 없으므로, 타깃의 프레임워크를 복사하기 위해서는 Build Phase의 "Link Binary With Libraries" 와 "Copy Files" 에 추가해야 합니다. 

 > Carthage는 동적 프레임워크를 빌드하기 때문에, 유효한 ID 코드 서명 설정이 필요합니다. 

1. [`Cartfile.private`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfileprivate) 에 Quick을 추가하세요:

    ```
    github "Quick/Quick"
    github "Quick/Nimble"
    ```

2. `carthage update`를 실행합니다.
3.  `Carthage/Build/[platform]/` 디렉터리에서, Quick과 Nimble을 test target의 Build Phase에 있는 "Link Binary With Libraries" 에 추가하세요:
    ![](http://i.imgur.com/pBkDDk5.png)

4. 테스트 타겟에 "Copy Files" 유형의 새 빌드 단계를 만들어 주세요:
    ![](http://i.imgur.com/jZATIjQ.png)

5. "Destination"을 "Frameworks"로 설정하고, 두 framework를 모두 추가해주세요:
    ![](http://i.imgur.com/rpnyWGH.png)

Carthage를 사용하여 의존성을 관리하는 것은 "유일한 방법" 이 아닙니다.
더 자세한 내용은 [Carthage 문서](https://github.com/Carthage/Carthage/blob/master/README.md)를 참조하십시오.

## [Swift 패키지 매니저](https://github.com/apple/swift-package-manager)
[swift.org](https://swift.org) 오픈 소스 프로젝트의 출현과 함께, Swift는 이제 초기지만, 공식적인 패키지 매니저 툴을 제공합니다. 특히, 처음으로 Quick을 비 Apple 플랫폼에서 사용할 수 있다는 가능성을 제공합니다. Swift 패키지 매니저를 사용하여 Quick 테스트 프로젝트를 사용할 수 있도록 초기 단계가 진행되었지만, 툴이 여전히 많이 개발되어 있지 않아 빈번히 파손될 것으로 예상됩니다. 

추가적인 문서가 더 작성될 때까지, 이 레퍼지토리는 어떻게 Quick이 SwiftPM용`Package.swift` 파일에서 종속성으로 선언되는 방법의 예로서 유용할 수 있습니다.

https://github.com/Quick/QuickOnLinuxExample

### (권장하지 않는 방법) 실제 iOS 기기에서 Quick Specs를 실행하기

Quick on Device로 작성된 Specs를 실행하려면, `Quick.framework`와 
`Nimble.framework`을 `Embedded Binaries`로 테스트 대상의  `Host Application`에 추가해야 합니다. 임베디드 바이너리로 프레임워크를 추가하면, Xcode가 자동으로 프레임워크와 앱을 연결해 줄 것입니다.

![](http://indiedev.kapsi.fi/images/embed-in-host.png)
