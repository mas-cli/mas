# All Files

- Before committing, run `Scripts/lint` to detect linting violations
- Run `Scripts/format` to automatically fix many linting violations
- Remove unnecessary trailing whitespace
  - Note that 2 trailing spaces is valid Markdown to create a line break like
    `<br>`, so those should _not_ be removed
- End each file with a [single newline character](
    https://unix.stackexchange.com/questions/18743/whats-the-point-in-adding-a-new-line-to-the-end-of-a-file#18789
  )

## Swift

[Sample](Sample.swift)

- Avoid [force unwrapping optionals](
    https://blog.timac.org/2017/0628-swift-banning-force-unwrapping-optionals
  ) with `!` in production code
  - Production code is located under the [`Sources/mas`](
      https://github.com/mas-cli/mas/tree/main/Sources/mas
    ) folder
  - However, force unwrapping is **encouraged** in tests for concision; tests
    _should_ break when any expected conditions aren't met
- Prefer `struct`s over `class`es wherever possible
- Default to marking classes as `final`
- Prefer protocol conformance to class inheritance
- Break lines at 120 characters
- Use tabs for indentation
- Use `let` whenever possible to make immutable bindings
- Name most parameters in functions & enum cases
- Use trailing closures
- Let the compiler infer the type whenever possible
- Group computed properties below stored properties
- Use a blank line above & below computed properties
- Apply the capitalization of the first letter throughout an acronym or
  initialism
- Use `()` for void arguments & `Void` for void return types
- Strongify weak references instead of evaluating them multiple times
