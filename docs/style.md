# All Files

- Use `script/format` to automatically fix a number of style violations.
- Remove unnecessary whitespace from the end of lines.
  - Use `script/lint` to look for these before committing.
  - Note that [two trailing spaces](https://gist.github.com/shaunlebron/746476e6e7a4d698b373)
     is intentional in markdown documents to create a line break like `<br>`, so these should _not_ be removed.
- End each file with a [newline character](https://unix.stackexchange.com/questions/18743/whats-the-point-in-adding-a-new-line-to-the-end-of-a-file#18789).

## Swift

[Sample](sample.swift)

- Avoid [force unwrapping optionals](https://blog.timac.org/2017/0628-swift-banning-force-unwrapping-optionals/)
with `!` in production code
  - Production code is what gets shipped with the app. Basically, everything under the
  [`mas-cli/`](https://github.com/mas-cli/mas/tree/main/mas-cli) folder.
  - However, force unwrapping is **encouraged** in tests for less code and tests
  _should_ break when any expected conditions aren't met.
- Prefer `struct`s over `class`es wherever possible
- Default to marking classes as `final`
- Prefer protocol conformance to class inheritance
- Break long lines after 120 characters
- Use 4 spaces for indentation
- Use `let` whenever possible to make immutable variables
- Name all parameters in functions and enum cases
- Use trailing closures
- Let the compiler infer the type whenever possible
- Group computed properties below stored properties
- Use a blank line above and below computed properties
- Group methods into specific extensions for each level of access control
- When capitalizing acronyms or initialisms, follow the capitalization of the first letter.
- When using `Void` in function signatures, prefer `()` for arguments and `Void` for return types.
- Prefer strong `IBOutlet` references.
- Avoid evaluating a weak reference multiple times in the same scope. Strongify first, then use the strong reference.
- Prefer to name `IBAction` and target/action methods using a verb describing the action it will trigger, instead
  of the user action (e.g., `edit:` instead of `editTapped:`)
