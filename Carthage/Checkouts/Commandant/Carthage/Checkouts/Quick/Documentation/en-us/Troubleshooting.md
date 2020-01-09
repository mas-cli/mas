# Common Installation Issues

Here are solutions to common issues that come up when using the framework.

## No such module 'Quick'

- If you have already run `pod install`, close and reopen the Xcode workspace. If this does not fix the issue, continue below.
- Delete the _entire_ `~/Library/Developer/Xcode/DerivedData` direction, which includes `ModuleCache`.
- Explicitly build (`Cmd+B`) the `Quick`, `Nimble`, and `Pods-ProjectNameTests` targets after enabled their schemes from the Manage Schemes dialog.