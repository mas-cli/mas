# Testing with Mocks

## Test doubles

Dependencies between objects can cause problems when writing tests. For example, say you have a `Car` class that depends on/uses `Tire`.

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesA.png)

`CarTests` tests `Car`, which calls `Tire`. Now bugs in `Tire` could cause `CarTests` to fail (even though `Car` is okay). It can be hard to answer the question: "What's broken?".

To avoid this problem, you can use a stand-in object for `Tire` in `CarTests`. In this case, we'll create a stand-in object for `Tire` called `PerfectTire`.

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesAmock.png)

`PerfectTire` will have all of the same public functions and properties as `Tire`. However, the implementation of some or all of those functions and properties will differ.

Objects like `PerfectTire` are called "test doubles". Test doubles are used as "stand-in objects" for testing the functionality of related objects in isolation. There are several kinds of test doubles:

- Mock object: Used for receiving output from a test class.
- Stub object: Used for providing input to a test class.
- Fake object: Behaves similarly to the original class, but in a simplified way.

Let's start with how to use mock objects.

## Mock

A mock object focuses on fully specifying the correct interaction with other objects and detecting when something goes awry. The mock object should know (in advance) the methods that should be called on it during the test and what values the mock object should return.

Mock objects are great because you can:

- Run tests a lot quicker.
- Run tests even if you're not connected to the Internet.
- Focus on testing classes in isolation from their dependencies.

### Writing Tests with Mock Objects in Swift

#### Sample app

For example, let's create an app which retrieves data from the Internet:

* Data from the Internet will be displayed in `ViewController`.
* A custom class will implement the `DataProviderProtocol`, which specifies methods for fetching data.

`DataProviderProtocol` is defined as follows:

```swift
protocol DataProviderProtocol: class {
    func fetch(callback: (data: String) -> Void)
}
```

`fetch()` gets data from the Internet and returns it using a `callback` closure.

Here is the `DataProvider` class, which conforms to the `DataProviderProtocol` protocol.

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

In our scenario, `fetch()` is called in the `viewDidLoad()` method of `ViewController`.

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

#### Testing using a Mock of `DataProviderProtocol`

`ViewController` depends on `DataProviderProtocol`. In order to test the view controller in isolation, you can create a mock object which conforms to `DataProviderProtocol`.

```swift
class MockDataProvider: NSObject, DataProviderProtocol {
    var fetchCalled = false
    func fetch(callback: (data: String) -> Void) {
        fetchCalled = true
        callback(data: "foobar")
    }
}
```

The `fetchCalled` property is set to `true` when `fetch()` is called, so that the test can confirm that it was called.

The following test verifies that when `ViewController` is loaded, the view controller calls `dataProvider.fetch()`.

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

If you're interested in learning more about writing tests, continue on to <https://realm.io/news/testing-in-swift/>.
