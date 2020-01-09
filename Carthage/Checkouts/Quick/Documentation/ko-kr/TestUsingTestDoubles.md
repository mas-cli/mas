# Mocks 테스트 (모의 테스트)

## Test doubles

객체 간 종속성으로 인해 테스트를 작성할 때 문제가 발생할 수 있습니다. 예를 들어, `Tire`에 의존하거나 사용하는 `Car` 클래스가 있다고 가정해봅시다.

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesA.png)

`CarTests`는  `Tire`라고 불리는 `Car`를 테스트합니다. 이제 `Tire`의 버그로 인해 `CarTests`가 실패할 수 있습니다. (`Car`는 괜찮습니다) 이는 "무엇이 망가졌는가?" 라는 질문에 대답하기 어려울 수 있습니다. 

이러한 문제를 피하려면, `CarTests`의 `Tire` 용 stand-in 객체를 사용할 수 있습니다. 이런 경우, `PerfectTire`라는 `Tire` 용 stand-in 객체를 만듭니다. 

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesAmock.png)

`PerfectTire` 는 `Tire` 와 모두 동일한 public 함수와 프로퍼티를 가질 겁니다. 하지만, 이러한 일부 또는 전체의 함수 또는 프로퍼티에 대한 구현은 다를 수 있습니다.

`PerfectTire` 와 같은 객체는 "test doubles"로 불립니다. Test doubles는 관련 객체의 기능을 독립적으로 테스트하기 위한 "stand-in objects"로 사용됩니다. 여기 몇 가지 종류의 test doubles가 있습니다:

- Mock 객체: 테스트 객체에서 결과물을 받기 위해 사용됩니다.
- Stub 객체:테스트 객체의 입력을 제공하는 데 사용됩니다.
- Fake 객체: 원래 클래스와 비슷하지만, 단순화된 방식으로 작동합니다.

Mock 객체의 사용법부터 알아봅시다.

## Mock

Mock 객체는 다른 객체와의 정확한 상호 작용을 열거하고, 무언가가 잘못되었을 때를 감지하는 데 초점을 둡니다. Mock 객체는 테스트가 진행되는 도중에 호출되어야 하는 메소드와 mock 객체가 반환해야 하는 값을 (미리) 알아야 합니다.

Mock 객체는 다음과 같은 이유로 훌륭합니다:

- 훨씬 더 빨리 테스트합니다.
- 인터넷에 연결되어 있지 않은 경우에도 테스트를 실행합니다.
- 클래스를 종속성과 분리하여 테스트하는 데 중점을 둡니다.

### Swift에서 Mock 객체로 테스트 작성하기

#### Sample app

예를 들어, 인터넷에서 데이터를 검색하는 앱을 만들어 봅시다:

* 인터넷의 데이터는 `ViewController`에 표시되어야 합니다. 
* 사용자 정의 클래스는 데이터를 가져오는 메서드를 지정하는 `DataProviderProtocol`을 상속합니다.

`DataProviderProtocol` 은 다음과 같이 정의됩니다:

```swift
protocol DataProviderProtocol: class {
    func fetch(callback: (data: String) -> Void)
}
```

`fetch()` 는 인터넷에서 데이터를 가져와 `callback` 클로저를 사용하여 데이터를 반환합니다. 

다음은, `DataProviderProtocol` 프로토콜을 따르는 `DataProvider`클래스 입니다. 

```swift
class DataProvider: NSObject, DataProviderProtocol {
    func fetch(callback: (data: String) -> Void) {
        let url = URL(string: "http://example.com/")!
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) {
            (data, resp, err) in
            let string = String(data: data!, encoding: .utf8)
            callback(data: string)
        }
        task.resume()
    }
}
```

이 시나리오에서, `fetch()` 는  `ViewController` 의 `viewDidLoad()` 메소드에서 호출됩니다.

```swift
class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var resultLabel: UILabel!
    private var dataProvider: DataProviderProtocol?

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataProvider = dataProvider ?? DataProvider()

        dataProvider?.fetch({ [unowned self] (data) -> Void in
            self.resultLabel.text = data
        })
    }
}
```

#### `DataProviderProtocol`의 Mock을 사용하여 테스트

`ViewController` 는 `DataProviderProtocol`을 신뢰합니다. 뷰 컨트롤러를 독립적으로 테스트하려면, `DataProviderProtocol` 을 따르는 mock 객체를 만들 수 있습니다.

```swift
class MockDataProvider: NSObject, DataProviderProtocol {
    var fetchCalled = false
    func fetch(callback: (data: String) -> Void) {
        fetchCalled = true
        callback(data: "foobar")
    }
}
```

 `fetch()` 가 호출되면, `fetchCalled` 프로퍼티가 `true`로 설정되어, 테스트에서 호출되었음을 확인할 수 있습니다.

다음 테스트에서는  `ViewController` 가 로드될 때, `dataProvider.fetch() `를 호출하는지 확인합니다. 

```swift
override func spec() {
    describe("view controller") {
        it("fetch data with data provider") {
            let mockProvider = MockDataProvider()
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            viewController.dataProvider = mockProvider

            expect(mockProvider.fetchCalled).to(beFalse())

            let _ = viewController.view

            expect(mockProvider.fetchCalled).to(beTrue())
        }
    }
}
```

테스트를 작성하는 것에 관해 관심이 있어서 더 배우고 싶다면, 다음을 참조하세요. <https://realm.io/news/testing-in-swift/>.
