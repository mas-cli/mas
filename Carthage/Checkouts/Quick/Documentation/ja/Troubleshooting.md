# トラブルシューティング

Quick を使用するときによくぶつかる問題の解決策を紹介します。

## Cocoapods でインストールした時に「No such module 'Quick'」エラーが出る

- すでに `pod install` を実行していた場合、一度 Xcode workspace を閉じて再度開いてみてください。それでも解決しない場合は次の手順を試してみてください。
- `ModuleCache` を含む `~/Library/Developer/Xcode/DerivedData` をすべて削除してください。
- `Manage Schemes`ダイアログから`Quick`、`Nimble`、`Pods-ProjectNameTests` ターゲットの Scheme が有効なことを確認して、明示的にビルド(`Cmd+B`)をやり直してみてください。
