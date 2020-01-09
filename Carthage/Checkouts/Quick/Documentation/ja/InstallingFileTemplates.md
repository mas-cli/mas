# Quickファイル・テンプレートのインストール方法

Quick のリポジトリには Swift, Objective-C の両方で使用できるテンプレートが含まれています。

## Alcatraz

Quick のテンプレートは Xcode のパッケージマネージャーの [Alcatraz](https://github.com/supermarin/Alcatraz) 経由でインストールできます。
パッケージマネージャーから検索してみてください。

![](http://f.cl.ly/items/3T3q0G1j0b2t1V0M0T04/Screen%20Shot%202014-06-27%20at%202.01.10%20PM.png)

## Rakefile から手動でインストールする

手動でインストールすることもできます。
リポジトリを clone して rake task の `templates:install` を実行してください。

```sh
$ git clone git@github.com:Quick/Quick.git
$ rake templates:install
```

アンインストールも簡単です、下記コマンドを実行してください。

```sh
$ rake templates:uninstall
```
