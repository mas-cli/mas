# テストの書き方、Quickの使い方

Quickでテストを書くと、SwiftとObjective-Cで書かれたプログラムがどう動作しているか楽に確認できます。

ところが、有用なテストはQuickを使わなくても書けます。
役に立つテストが書けるようになるには、Quickのようなフレームワークの使い方を覚える必要はありません。

このディレクトリにあるファイルは、QuickかXCTestかを問わず、
「役に立つ」テストとは何か、そしてどうやってそういったテストが書けるか、
それを拙文ながら説明しようとしています。

目次：

（テストについて事前知識がまったくない方は、順に読んでいくことをオススメします。）

- **[Xcodeでテストを用意しましょう](SettingUpYourXcodeProject.md)**:
  アプリのコードがテスト・ファイルから参照できない場合や、
  その他スムーズにテストが動かない場合はこのファイルを読み返すといいかもしれません。
- **[XCTestで役に立つテストを書く方法：Arrange（環境構築）, Act（実行）, and Assert（動作確認）](ArrangeActAssert.md)**:
  役に立つテストを書くための基本中の基本。これさえ覚えれば、
  XCTestを使ってあなたも正確に動作するコードをすばやく書けるようになります。
- **[コードをテストするのではなく、動作の確認をしましょう](BehavioralTesting.md)**:
  同じ「テスト」でも、開発を進めやすくするテストと、邪魔ばかりするテストとがあります。
  見分ける方法は、このファイルを読めば分かります。
- **[Nimbleのassertでテストをより読みやすくしましょう](NimbleAssertions.md)**:
  Nimbleを使って、テストが失敗したときわかりやすいエラーメッセージを出すようにしましょう。
  わかりやすいメッセージで、テストがなぜ失敗したのかが一瞬でわかって開発の速度があがります。
- **[QuickのExamplesとExample Groupsで、たくさんのテストでも整理整頓](QuickExamplesAndGroups.md)**:
  Quickを使う大きなメリットのひとつはexamplesとexample groupsです。
  これでより簡潔にたくさんのテストが書けるようになります。
- **[OS XとiOSアプリのテスト](TestingApps.md)**:
  AppKitとUIKitを使ったコードをどうやってテストできるか説明します。
- **[Test doublesを使ったテスト](TestUsingTestDoubles.md)**:
  Test doublesを使って対象のクラスのみをテストする方法を説明します。
- **[assertの共有でボイラープレートコードをなくしましょう](SharedExamples.md)**:
  どうやってassertを共有できるか、なぜそうするのが望ましいのか説明します。
- **[Quickの挙動をカスタマイズしましょう](ConfiguringQuick.md)**:
  Quickがテストを実行するときの挙動をどうやって変えられるか説明します。
- **[Objective-CでQuickを使う方法・注意点](QuickInObjectiveC.md)**:
  QuickをObjective-Cで使ったときに思わぬ不具合・トラブルがあった場合、
  これを読んでください。
- **[Quickのインストール方法](InstallingQuick.md)**:
  あなたのプロジェクトにQuickを導入する方法を説明します。Git submodules、
  CocoaPods、Carthage、全部サポートしています！
- **[Quickファイル・テンプレートのインストール方法](InstallingFileTemplates.md)**:
  Quickテストをすばやく作成するためのファイル・テンプレートをインストールする方法を説明します。
- **[その他の参考資料](MoreResources.md)**:
  OS X・iOSのテストに関しての資料集を用意しています。
- **[トラブルシューティング](Troubleshooting.md)**:
  その他の不具合に遭遇した場合にこれを読んでください。
