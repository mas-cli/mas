# All Files

- Use `Scripts/format` to automatically fix a number of style violations.
- Remove unnecessary whitespace from the end of lines.
  - Use `Scripts/lint` to look for these before committing.
  - Note that two trailing spaces is valid Markdown to create a line break like `<br>`,
    so those should _not_ be removed.
- End each file with a [newline character](
    https://unix.stackexchange.com/questions/18743/whats-the-point-in-adding-a-new-line-to-the-end-of-a-file#18789
  ).

## Swift

[Sample](sample.swift)

- Avoid [force unwrapping optionals](https://blog.timac.org/2017/0628-swift-banning-force-unwrapping-optionals)
with `!` in production code
  - Production code is what gets shipped with the app. Basically, everything under the
  [`Sources/mas`](https://github.com/mas-cli/mas/tree/main/Sources/mas) folder.
  - However, force unwrapping is **encouraged** in tests for less code & tests
  _should_ break when any expected conditions aren't met.
- Prefer `struct`s over `class`es wherever possible
- Default to marking classes as `final`
- Prefer protocol conformance to class inheritance
- Break lines at 120 characters
- Use 4 spaces for indentation
- Use `let` whenever possible to make immutable variables
- Name all parameters in functions & enum cases
- Use trailing closures
- Let the compiler infer the type whenever possible
- Group computed properties below stored properties
- Use a blank line above & below computed properties
- Group functions into separate extensions for each level of access control
- When capitalizing acronyms or initialisms, follow the capitalization of the first letter.
- When using `Void` in function signatures, prefer `()` for arguments & `Void` for return types.
- Avoid evaluating a weak reference multiple times in the same scope. Strongify first, then use the strong reference.
