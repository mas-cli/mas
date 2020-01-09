# 使用模拟对象进行测试

## 测试替身

下面的问题在写测试时经常出现。比如：`Car` 依赖于／使用 `Tire` 。

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesA.png)

`CarTests` 用来测试调用了 `Tire` 的 `Car` 。这时候，在 `Tire` 里出现的 bug 会导致 `CarTests` 测试失败（即使 `Car` 是没有错误的）。

这时候很难说清楚到底是什么出错了。为了避免这个问题，我们可以使用一个替身对象，来代替 `CarTests` 里面的 `Tire` 。对于这个问题，我们会为 `Tire` 创建一个替身对象，命名为 `PerfectTire` 。

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesAmock.png)

`PerfectTire` 具有和 `Tire` 一样的函数和属性。但是，这些函数和属性的实现可能会有所不同。

像 `PerfectTire` 这样的对象叫做“测试替身”。测试替身充当替身对象，用于独立测试多个相关对象的功能。以下是测试替身的几种类型：

- 模拟对象：用于从测试类中接收输出。
- 桩对象：用于为测试类提供输入。
- 伪对象：具有与原来的类相似的行为。

我们先了解一下如何使用模拟对象。

## 模拟对象

模拟对象着眼于说明它与其它对象的正确交互，并且当出现错误时用来检测问题。模拟对象应该事先知道测试时会发生什么，并且该做出怎样的反应。

### 在 Swift 中使用模拟对象来写测试

#### 应用案例

例如，我们有一个应用，它会从互联网上获取数据。

* 在 `ViewController` 中展示从互联网上获取的数据。
* 自定义类，实现 `DataProviderProtocol` ，负责获取数据。

`DataProviderProtocol` 如下定义：

```swift
protocol DataProviderProtocol: class {
    func fetch(callback: (data: String) -> Void)
}
```

`fetch()` 从互联网上获取数据，并通过闭包 `callback` 返回数据。

下面的 `DataProvider` 实现了 `DataProviderProtocol` 协议。

```swift
class DataProvider: NSObject, DataProviderProtocol {
    func fetch(callback: (data: String) -> Void) {
        let url = NSURL(string: "http://example.com/")!
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithURL(url, completionHandler: {
            (data, resp, err) in
            let string = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
            callback(data: string)
        })
        task.resume()
    }
}
```

在我们这个场景里，`ViewController` 的 `viewDidLoad()` 里调用了 `fetch()` 。

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

#### 用 `DataProviderProtocol` 协议的模拟对象进行测试

`ViewController` 依赖于 `DataProviderProtocol` 协议。为了测试这个 viewController ，要创建一个遵循 `DataProviderProtocol` 的模拟对象。

模拟对象是非常有用的。因为使用它，你可以：

- 更快地运行测试。
- 即使未联网也可以进行测试。
- 对 `ViewController` 进行独立测试。

```swift
class MockDataProvider: NSObject, DataProviderProtocol {
    var fetchCalled = false
    func fetch(callback: (data: String) -> Void) {
        fetchCalled = true
        callback(data: "foobar")
    }
}
```

当 `fetch()` 被调用的时候，`fetchCalled` 会被设为 `true` 。这样能使测试代码确认对象是否准备好进行测试。

下面的代码验证了当 `ViewController` 加载时，会运行 `dataProvider.fetch()` 。

```swift
override func spec() {
    describe("view controller") {
        it("fetch data with data provider") {
            let mockProvier = MockDataProvider()
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            viewController.dataProvier = mockProvier

            expect(mockProvier.fetchCalled).to(equal(false))

            let _ = viewController.view

            expect(mockProvier.fetchCalled).to(equal(true))
        }
    }
}
```

如果你对写测试感兴趣，想学习更多的内容，请参考 https://realm.io/news/testing-in-swift/ 。


