# Project Guidelines

## Purpose & Scope

This file is the canonical source of project conventions for humans & agents.
Read it before making repository changes.

## Minimum Versions

- **Swift:** 6.3
- **Xcode:** 26.4
- **macOS:** 13

## Quick Entry Points

- `Scripts/bootstrap`
- `Scripts/format`
- `Scripts/lint -AP` (quick) / `Scripts/lint` (includes unused code checks)
- `Scripts/build` (debug) / `Scripts/build '' -c release` (release)
- `Scripts/test`
- `Scripts/package`

## Git Workflow

- `main` is the trunk
- Branch topics from `main`
- Before committing (to preserve tokens, agents should skip all of the following
  steps unless explicitly directed to perform them):
  1. Add or edit tests for non-trivial changes
  2. Repeatedly run `Scripts/format` until no modifications are made
  3. Repeatedly run `Scripts/lint` & fix all violations until no violations are
     reported
- **Commit messages:** Follow [commit message conventions](
    https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  )
- Tag releases as `vX.Y.Z`

## Content Formatting

- **Newlines:** Unix (i.e. `\n`)
- **Indentation:** Tabs (2 characters wide) for all files unless otherwise
  specified; 2 spaces for YAML; 1 space for Markdown
- **Max line length:** 120 characters for all files unless otherwise specified
  (tabs count as 2 characters); 80 for Markdown; unlimited for header, JSON &
  swiftformat
- **Unnecessary trailing whitespace:** Remove
- **File ends:** Single newline
- **Quoting:** Quote strings only when necessary, preferring the most literal
  format that works over more interpreted formats; if multiple quote syntaxes
  are functionally equivalent, prefer the visually lightest, e.g., prefer single
  quotes over double quotes if they are functionally equivalent
- **Text**: In documentation, comments, strings, etc.:
  - **Commas:** Use Oxford commas for lists
  - **Ampersands:** Prefer `&` to `and` (omit Oxford comma before `&`)
  - **Exceptions:** `and` should be used in `and/or` & after a comma that
    separates distinct clauses (but not in a list)
  - **Quotes**: The enclosing quotations marks of a quote at the end of a
    sentence (iff the whole sentence isn't a quote) should not enclose the
    terminal punctuation mark of the encompassing sentence
  - **Iff**: Use `iff` as `if & only if`

### Markdown Guidelines

- **Style:** GitHub-Flavored Markdown (GFM), ATX headings, backtick-fenced code
  blocks with language identifier, underscore emphasis, asterisk strong & hyphen
  bullets
- **HTML:** Limit to HTML supported by GFM that doesn't have a native GFM
  equivalent

## Refactoring Rules

Unless absolutely necessary for functionality or fixes, or unless violations of
standards are discovered, do not:

- reformat
- rename
- reorder
- respace
- reword
- remove comments
- refactor if it worsens the caller interface

Refactoring should:

- Keep clean abstractions
- Inline a utility iff it is single-use
- Replace a utility iff the new version is more correct, performant, and/or
  simpler than the existing version, in descending order of priority

## Scripting

- Use zsh for scripts (except for shell-specific completion scripts)
- Zsh scripts must be compatible with all zsh versions starting with the version
  ([currently 5.9](https://opensource.apple.com/releases/)) bundled with the
  newest version ([currently 13.5.x](https://opensource.apple.com/releases/))
  of the oldest macOS major version supported by mas
  ([currently 13](Package.swift))
- Use `#!/bin/zsh` shebang (with `-Ndefgku` options, unless any changes to the
  options are absolutely necessary)
- Run `. "${0:A:h}/_setup_script"` at the start of all development scripts
- Prefer concision over verbosity
- If performance is at least almost equivalent or better, prefer in descending
  order:
  - zsh expansions
  - zsh globs
  - zsh builtins
  - zsh loops
  - external commands
- Make variables local & readonly when possible
- Use:
  - `cp -c` instead of `cp`
  - `trash` instead of `rm`

## Swift

mas is a SwiftPM project that uses Swift Argument Parser to interact with the
command-line.

### Apple Private Frameworks

The `PrivateFrameworks` SwiftPM target exposes the following Apple private
frameworks (via Objective-C headers extracted from the DSC) to deploy App Store
apps:

- **CommerceKit:** Controllers
- **StoreFoundation:** Models

Use private frameworks only when public APIs are insufficient.

Newer Apple private frameworks (e.g., AppStoreDaemon & AppleMediaServices) seem
to supersede the currently used ones, but the newer ones seem usable only by
code with Apple-exclusive entitlements.

### Swift Source Folder Hierarchy

Swift source is organized in subfolders of `Sources/mas`:

- **Commands:** CLI implementation
- **Models:** Data types & suppliers
- **Utilities:** Utilities

### Command Implementation Patterns

Commands follow a consistent structure:

- Commands are nested structs within the `MAS` main command
- Use `@OptionGroup` to compose reusable argument sets from dedicated types
  that conform to `ParsableArguments`
- Implement `func run() async { … }` as the main command entry point
- Use the static `MAS.printer` for all output to ensure consistent formatting
- Call methods on `AppStoreAction` enum cases (accessible via the `AppStore`
  typealias) to execute business logic, e.g., `await AppStore.install.apps(…)`

### Style Essentials

- Name most function parameters
- Capitalize acronym & initialism characters consistently (e.g., `ADAM`, `API`,
  `HTTPRequest`, `JSON`)
- Shadow variables if the respective original will no longer be used
- Strongify weak references instead of evaluating them multiple times
- Group computed properties below stored properties

### Code Preference Hierarchies

Each subsection contains code preferences in descending order.

Within this section & all subsections, `X` is a placeholder for any type name.

#### Naming

1. Standardized name
2. Concise name
3. Verbose name

#### Concision/Verbosity

1. Concise code, e.g.:
   - Optional binding shorthand (e.g., `if let x { … }`, not
     `if let x = x{ … }`)
2. Verbose code

#### Architecture

1. Composition
2. Protocol conformance
3. Class inheritance

#### Typing

1. Inferred type, e.g.:
   - `var a = [X]()`
   - `var o = X?.none`
   - `var c: X { .init() }`
   - `f(array: .init())`
   - `f(dictionary: .init())`
2. Cast type, e.g.:
   - `var a = [] as [X]`
   - `var o = nil as X?`
3. Explicit type, e.g.:
   - `var a: [X] = .init()`
   - `var o: X? = nil`
   - `var c: X { X() }`
   - `f(array: [])`
   - `f(dictionary: [:])`

#### Functional

1. Functional
2. Non-functional

#### Value Inlining/Binding

1. Inlined single-use value
2. `let` multiple-use value
3. `var` multiple-use value

#### Code Inlining/Reuse

1. Inlined single-use code (unless inlined code is much more complex)
2. Computed property
3. Function

#### Optional Handling

1. Nil-coalescing operator (`??`)
2. Ternary operator
3. `Optional.map(_:)` / `Optional.flatMap(_:)`
4. Single `guard`
5. `if` / `else` (no `else if`)
6. `switch`
7. Multiple `guard`
8. `if` / `else if`… / `else`
9. `preconditionFailure(_:file:line:)`
10. Forced unwrapping (`!` suffix)
11. `fatalError(_:file:line:)`

#### Throwing

1. Typed throws (`throws(ErrorType)`)
2. Untyped rethrows (`rethrows`)
3. Untyped throws (`throws`)

#### Code Reuse

1. Framework/library call
2. Custom code

#### Constants

1. Global `let`
2. `enum` `static let`
3. `struct` `static let`
4. `class` `static let`

#### Preferred Types

1. Unaliased infrequent tuple/closure
2. Type-aliased frequent tuple/closure
3. `enum`
4. `struct`
5. `actor`
6. `final class`
7. `class`

#### Type Syntax

1. Concision:
   - Generics: `<T: X>`
   - Optional: `X?`
   - Collection: `[X]`
   - Dictionary: `[X:X]`
2. Verbosity:
   - Generics: `where T: X`
   - Optional: `Optional<X>`
   - Collection: `Array<X>`
   - Dictionary: `Dictionary<X, X>`

#### Void Types

1. `()` for void parameter type
2. `Void` for void return type

#### Closure Syntax

1. Trailing closure
2. Inline closure

#### Closure Arguments

1. Shorthand argument names (e.g., `$0`) iff one-line closure
2. Explicit argument names for multi-line closure

#### Functional Arguments

1. KeyPath
2. Function reference
3. Closure

#### Strict Memory Safety

1. Memory-safe code (i.e. not `unsafe`)
2. `unsafe` code iff a memory-safe alternative:
   - Is not available from frameworks/libraries
   - Is too difficult to implement properly & performantly

### Testing Requirements

- Add tests for all non-trivial changes (to preserve tokens, agents should not
  add tests unless explicitly directed to do so)
- Implement in [Swift Testing](https://github.com/swiftlang/swift-testing)
- Derive test file paths from source file paths:
  - replace the `Sources/mas` source path folder prefix with `Tests/MASTests`
  - prepend `MASTests+` to the source file name
  - e.g., `Sources/mas/Commands/X.swift` →
    `Tests/MASTests/Commands/MASTests+X.swift`
- Use force unwrapping in tests where appropriate
