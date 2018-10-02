# Test doubles を使ったテスト

## Test doubles

テストを書いているとしばしば次のような問題にぶつかります。 `車`クラスが`タイヤ`クラスを使用している(依存している)とします。

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesA.png)

ここで 車Tests という (`タイヤ`に依存している)`車` のテストを用意します。ここで `タイヤ` にバグがあった場合、`車`に問題なくても 車Tests は失敗します。
このような事が頻繁に起こるとバグの究明が難しくなります。

この問題を回避するには、`車`Tests において `タイヤ`の 代わりになるクラス`完璧タイヤ` クラス(代理、英語で `Stand-in`といいます)を用意する、という方法があります。

![](https://github.com/Quick/Assets/blob/master/Screenshots/TestUsingMock_BusesAmock.png)

この`完璧タイヤ`は実装は異なりますが`タイヤ`と同じメソッド、プロパティを持ちます。そのため 車Tests において `タイヤ` を `完璧タイヤ` と入れ替えることができます。

`完璧タイヤ`クラスのような差し替え可能なオブジェクトのことを一般に'test doubles(テストダブル)'と呼びます。
'test doubles' にはいくつか種類があります。

- Mock object: テスト対象のクラスの出力の検証に用いる
- Stub object: テスト対象のクラスにデータを渡す(入力)際に用いる
- Fake object: 差し替え前のオブジェクトと近い振る舞いをする(実装がより簡単になっている)

ここではモックを使ったテストの方法を紹介します。

## モックとは

モックとはテスト対象のオブジェクト(クラス、構造体)が呼び出し先のオブジェクトと意図したとおりに協調動作するかどうかをテストするために使うオブジェクトのことです。

## Swift でモックを使ったテストを書く

### サンプルアプリケーション

ここでは例としてインターネット経由で取得したデータを表示するアプリケーションを考えます。

* DataProviderProtocolというプロトコルを実装したクラスがインターネット経由でデータを取得する
* 取得したデータをViewControllerで表示する

ここで DataProviderProtocol を定義します。

```swift
// Swift
protocol DataProviderProtocol: class {
    func fetch(callback: (data: String) -> Void)
}
```

DataProviderProtocol の `fetch()`関数でデータを取得し、callbackブロックでデータを渡します。

ここで DataProviderProtocol を実装する DataProvider クラスを定義します。

```swift
// Swift
class DataProvider: NSObject, DataProviderProtocol {
    func fetch(callback: (data: String) -> Void) {
        let url  = NSURL(string: "http://example.com/")!
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task    = session.dataTaskWithURL(url, completionHandler: {
            (data, resp, err) in
            let string = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
            callback(data: string)
        })
        task.resume()
    }
}
```

ViewController の `viewDidLoad` 中にデータの取得(`fetch()`の呼び出し)を行います。

コードはこのようになります。

```swift
// Swift
class ViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    private var dataProvider: DataProviderProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataProvider = dataProvider ?? DataProvider()

        dataProvider?.fetch({ [unowned self] (data) -> Void in
            self.resultLabel.text = data
        })
    }
}
```

## DataProviderProtocol のモックを使ったテストを書く

この例では ViewController は DataProviderProtocol に依存しています。
テスト用に DataProviderProtocol を継承したクラス(モックとして使用します)をテストターゲット内に作成します。

モックを作成することで、
- テストを速く実行できる
- インターネットに接続していなくてもテストができるようになる
- ViewController の動作のテストにフォーカスできる（実際のDataProviderをテスト対象から外すことが出来る）

```swift
// Swift
class MockDataProvider: NSObject, DataProviderProtocol {
    var fetchCalled = false
    func fetch(callback: (data: String) -> Void) {
        fetchCalled = true
        callback(data: "foobar")
    }
}
```

このモックの中で fetchCalled プロパティを定義しています。 fetchCalled は fetch 関数が呼ばれたら true になります。
これで準備は完了です。

このモックを使ってテストをします。このテストで「 ViewController がロードされた時(viewDidLoad)に dataProvider を使って fetch() を実行するか」という動作をテストしています。

```swift
// Swift
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

このようにオブジェクトのモックを作ることで動作をテストしやすくなります。

テストの書き方について、更に詳細を知りたい方はこちらのビデオを参考にしてください。 https://realm.io/jp/news/testing-in-swift/ 。
