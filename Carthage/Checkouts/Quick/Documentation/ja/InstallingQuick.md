# Quickのインストール方法

> **もし Xcode 7.1 を使用していたら** 現時点で最新バージョンの Quick--`v0.9.0` を使用してください
> 最新のリリースは `swift-2.0` branch で開発されています。

Quick は examples(テスト) and example groups(テストグループ)の文法を提供します。
Nimble は `expect(...).to` の文法を提供します。
テストでは両方を使ってもいいですし、どちらか片方を使う、ということもできます。

Quick をテストに組み込むには３つの方法があります。

1. [Git Submodules](#git-submodules)
2. [CocoaPods](#cocoapods)
3. [Carthage](#carthage)

下記のインストール手順の中からどれか選択してインストールを進めてください。
インストール完了後、テストターゲット内のファイルで Quick を使用(`import Quick`)できるようになります。

## Git Submodules

Git submodules を使って Quick と Nimble をリンクします。手順の流れとしては下記の通りです。

1. Quick を submodule として追加.
2. プロジェクトで`.xcworkspace`を使っていなければ作成してください。 ([こちらを参照](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_an_Existing_Project_to_a_Workspace.html))
3. `Quick.xcodeproj` をプロジェクトの`.xcworkspace`に追加してください。
4. `Nimble.xcodeproj` をプロジェクトの`.xcworkspace`に追加してください。 `Nimble.xcodeproj` は `path/to/Quick/Externals/Nimble` にあります。 Quick が依存している Niimble を追加することで Quick のバージョンと Nimble のバージョンを合わせられます。

5. `Quick.framework` と `Nimble.framework` を BuildPhase の "Link Binary with Libraries" でリンクします。

もしまだ git submodules 用のディレクトリを作っていなかったら、まず始めにディレクトリを作成します。
`Vendor` という名前のディレクトリを用意しましょう。

**Step 1:** Quick と Nimble を Git submodules としてダウンロードする

```sh
git submodule add git@github.com:Quick/Quick.git Vendor/Quick
git submodule add git@github.com:Quick/Nimble.git Vendor/Nimble
git submodule update --init --recursive
```

**Step 2:** `Quick.xcodeproj` と `Nimble.xcodeproj` をプロジェクトの `.xcworkspace` に追加してください。
例として `Guanaco.xcworkspace` という workspace に Quick と Nimble を追加します。

![](http://f.cl.ly/items/2b2R0e1h09003u2f0Z3U/Screen%20Shot%202015-02-27%20at%202.19.37%20PM.png)

**Step 3:** build phase の `Link Binary with Libraries` に `Quick.framework` を追加してください。
2種類の `Quick.frameworks` が表示されますが 1 つは OS X 用で、もう 1 つが iOS 用です。

![](http://cl.ly/image/2L0G0H1a173C/Screen%20Shot%202014-06-08%20at%204.27.48%20AM.png)

`Nimble.framework` も同様に追加してください。これで完了です！

**Submodules をアップデートする:** Quick と Nimble を最新バージョンにアップデートしたい場合は Quick ディレクトリに入って master リポジトリから pull してください。

```sh
cd /path/to/your/project/Vendor/Quick
git checkout master
git pull --rebase origin master
```

あなたのプロジェクトの Git リポジトリは submodule の変更もトラッキングしているので Quick submodules の更新を commit しておきます。

```sh
cd /path/to/your/project
git commit -m "Updated Quick submodule"
```

**Quick Submodule を含んだ リポジトリを git clone する:** 他の開発者があなたのリポジトリを clone したあと、submodules を同様に pull してくる必要があります。`git submodule update` コマンドを実行することで pull できます。

```sh
git submodule update --init --recursive
```

git submodules に詳細な情報は[こちら](http://git-scm.com/book/en/Git-Tools-Submodules)です。

## CocoaPods

CocoaPods でインストールする場合、バージョンは 0.36.0 以降である必要(CocoaPods が Swift をサポートしているバージョン)があります。

Podfile に Quick と Nimble を追加して下さい。 Swift では ```use_frameworks!``` も必要です。

```rb

# Podfile

use_frameworks!

def testing_pods
    pod 'Quick', '~> 0.9.0'
    pod 'Nimble', '3.0.0'
end

target 'MyTests' do
    testing_pods
end

target 'MyUITests' do
    testing_pods
end
```

その後 pod install でダウンロード、リンクします。

```sh
pod install
```

### Swift 1.2 で使う

Quick の最新版(0.4.0)は Swift 2 (Xcode 7) 用ですが、Nimble の最新版(1.0.0) は Swift 1.2 (Xcode 6) 用です。

もし Xcode6 で使いたい場合は下記のようにバージョン指定してください。

```sh
target 'MyTests' do
  use_frameworks!
  pod 'Quick', '~>0.3.0'
  pod 'Nimble', '~>1.0.0'
end
```

## [Carthage](https://github.com/Carthage/Carthage)

テストターゲットは "Embedded Binaries" section がないので framework はターゲットの "Link Binary With Libraries" に追加する必要があります。 build phase の "Copy Files" も同様にターゲットの framework destination を指定して下さい。

 > Carthage は dynamic frameworks をビルドするので code signing identity に有効なものを設定しておく必要があります。

1.  Quick を [`Cartfile.private`](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfileprivate) に追加してください。

    ```
    github "Quick/Quick"
    github "Quick/Nimble"
    ```

2. `carthage update` を実行してください。
3. `Carthage/Build/[platform]/` ディレクトリから Quick と Nimble をテストターゲットの "Link Binary With Libraries" に追加してください。
    ![](http://i.imgur.com/pBkDDk5.png)

4. テストターゲットの build phase で "New Copy Files Phase" を選択してください。
    ![](http://i.imgur.com/jZATIjQ.png)

5. "Destination" を "Frameworks" に設定して、２つの framework を追加してください。
    ![](http://i.imgur.com/rpnyWGH.png)

Carthage の dependency の管理方法はこの方法だけではありません。
詳細な情報はこちらを参照してください [Carthage documentation](https://github.com/Carthage/Carthage/blob/master/README.md) 。

### (非推奨) 実機で Quick のテストを走らせる

Quick で書かれたテストを実機で走らせるためには `Quick.framework` と `Nimble.framework` を `Embedded Binaries` としてテストターゲットの `ホストアプリケーション` に追加されます。 Embedded binary として framework を追加すると Xcode が自動的にホストアプリケーションにリンクしてしまいます。

![](http://indiedev.kapsi.fi/images/embed-in-host.png)
