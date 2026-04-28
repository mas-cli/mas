# Project Guidelines

## Notes for automated/codegen agents

- Read this `AGENTS.md` in full before making any changes to the repository; it
  is the canonical source of project conventions
- No repository-level AI instruction files were found (e.g.,
  `.github/copilot-instructions.md`, `AGENT.md`, `CLAUDE.md`, or
  `.cursor`/`.cursorrules` files); rely on this document & the concrete files
  listed below
- Quick entry points (use these scripts rather than invoking swift directly when
  possible):
  - `Scripts/bootstrap`
  - `Scripts/format`
  - `Scripts/lint -AP` (quick) / `Scripts/lint` (full)
  - `Scripts/test`
  - `Scripts/build` / `Scripts/build '' -c release`
- Useful code locations & examples (look here for patterns to follow):
  - CLI commands: `Sources/mas/Commands/` (e.g. `Install.swift`, `List.swift`)
  - Models: `Sources/mas/Models/` (e.g. `AppID.swift`, `CatalogApp.swift`)
  - Utilities: `Sources/mas/Utilities/` (e.g. `Output/Printer.swift`)
  - Tests & test naming: `Tests/MASTests/` (see `MASTests+*.swift` files)
  - Private framework headers: `Sources/PrivateFrameworks/include/CommerceKit/`
    & `Sources/PrivateFrameworks/include/StoreFoundation/` (used via the
    `PrivateFrameworks` target)
  - Build plugin: `Plugins/MASBuildToolPlugin/MASBuildToolPlugin.swift`
  - Completion scripts: `contrib/completion/` (bash/fish)
  - Packaged runtime: `libexec/bin/mas` (used by `Scripts/mas` wrapper)
- Edits & commits: preserve formatting & style (tabs, max line length, single
  newline at EOF).
- Before committing automated edits: run `Scripts/format` until it no longer
  changes files, then `Scripts/lint` & fix violations.

## Code Refactoring Guidelines

Do NOT refactor code if doing so makes the caller interface worse. Specifically:

- **Inline a utility function or computed var at a call site iff it is
  single-use**. Inlining multi-use functions or computed vars increases
  verbosity, introduces duplication bugs & makes code harder to maintain. Keep
  clean abstractions. Example of what NOT to do:
  ```swift
  // ❌ BAD: Inlining uppercasingFirst at multiple call sites
  action1.performing.prefix(1).uppercased() + action.performing.dropFirst()
  action2.performing.prefix(1).uppercased() + action.performing.dropFirst()
  // ✅ GOOD: Use the utility function
  action1.performing.uppercasingFirst
  action2.performing.uppercasingFirst
  ```
- **Never replace a clean, readable abstraction with a verbose closure**. e.g.,
  if a custom `SortComparator` or similar is used multiple times, keep it.
  Consider inlining only if the abstraction is used in exactly one place.
  Example of what NOT to do:
  ```swift
  // ❌ BAD: Replacing a clean comparator with verbose closure
  [6, 9, 3].sorted { $0.compare($1, options: .numeric) == .orderedAscending }
  [2, 8, 4].sorted { $0.compare($1, options: .numeric) == .orderedAscending }
  // ✅ GOOD: Keep the abstraction
  [6, 9, 3].sorted(using: NumericStringComparator.forward)
  [2, 8, 4].sorted(using: NumericStringComparator.forward)
  ```
- **Replace a utility call** only when the new calling interface is at least as
  simple as the current calling interface
- **Replace a utility implementation** when the new implementation is more
  correct, performant, and/or simpler than the existing implementation, in
  descending order of priority

## Minimum Versions

- **Swift**: [6.2](.swift-version)
- **Xcode**: [26](.xcode-version)
- **macOS**: [13](Package.swift)

## Distributions

1. [Homebrew Core](https://formulae.brew.sh/formula/mas) (`brew install mas` for
   macOS 14+)
2. [Homebrew custom tap formula](https://github.com/mas-cli/homebrew-tap)
   (`brew install mas-cli/tap/mas` for macOS 13+)
3. [GitHub Releases](https://github.com/mas-cli/mas/releases)
4. [MacPorts](https://ports.macports.org/port/mas/)
5. [Nix](https://mynixos.com/nixpkgs/package/mas)

## Development Workflows

### Bootstrap Development Tools

```shell
Scripts/bootstrap
```

### Lint (quick)

```shell
Scripts/lint -AP
```

### Lint (slow, includes unused code checks)

```shell
Scripts/lint
```

### Format

```shell
Scripts/format
```

### Build (debug)

```shell
Scripts/build
```

### Build (release)

```shell
Scripts/build '' -c release
```

### Test

```shell
Scripts/test
```

### Package

```shell
Scripts/package
```

## Git Workflow

- **Trunk-based development**: `main` is the trunk
- **Topic branches**: Branch from `main` (e.g., `git checkout -b feature main`)
- **Commit messages**: Follow [commit message conventions](
    https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  )
- **Release tags**: Format like `v1.2.3`
- **Before committing**: Run `Scripts/format` repeatedly until it no longer
  modifies any files, then run `Scripts/lint`, then fix all violations

## Content Formatting

- **Newlines**: UNIX (i.e. `\n`)
- **Indentation**: Tabs (width: 2)
- **Max line length**: 120 characters
- **Unnecessary trailing whitespace**: Remove
- **File ends**: Single newline

## Content Preservation

Unless absolutely necessary for functionality or fixes, do not:

- reformat
- rename
- reorder
- respace
- reword
- remove comments

## Scripting

### Zsh

All scripting must be written in zsh, except completion scripts (which are
written in their target shell).

Zsh scripts must be compatible with all zsh versions starting with the version
([currently 5.9](https://opensource.apple.com/releases/)) bundled with the
newest version ([currently 13.5.x](https://opensource.apple.com/releases/))
of the oldest-mas-supported macOS major version ([currently 13](Package.swift)).

### Safe Operations

- Use `#!/bin/zsh` shebang (with `-Ndefgku` options, unless any changes to the
  options are absolutely necessary)
- Run `. "${0:A:h}/_setup_script"` at the beginning of all development scripts
- Prefer concision over verbosity (e.g., expansions over loops)
- Prefer zsh syntax & builtins over equivalent external commands
- Ensure all function variables are local unless global is absolutely necessary
- Make variables readonly once they will no longer be modified
- Always use:
  - `cp -c` instead of `cp`
  - `trash` instead of `rm`

## Swift

### Project Structure

mas is a SwiftPM project that uses Swift Argument Parser to interact with the
command-line.

### Apple Private Frameworks

The `PrivateFrameworks` SwiftPM target allows using the following Apple private
frameworks (via Objective-C headers extracted from the DSC) to deploy App Store
apps:

- **CommerceKit**: Controllers
- **StoreFoundation**: Models

Use them only where public APIs are insufficient.

Newer Apple private frameworks (e.g., AppStoreDaemon) seem to supersede the
currently used ones, but the newer ones seem usable only by code with
Apple-exclusive entitlements.

### Source Folder Hierarchy

Source is organized by concern:

- **AppStore/**: App Store integration
- **Commands/**: CLI implementation
- **Models/**: Data types
- **Utilities/**: Utilities

### Style Essentials

- Avoid force unwrapping (`!` suffix) in code under `Sources/mas/` folder
- Name most function parameters
- Capitalize acronym & initialism characters consistently (e.g., `HTTPRequest`,
  not `HttpRequest`)
- Group computed properties below stored properties
- Use blank lines above & below each section
- Shadow variables if the respective original will no longer be used
- Strongify weak references instead of evaluating them multiple times

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

- Write tests for all non-trivial changes
- Implement in [Swift Testing](https://github.com/swiftlang/swift-testing)
- Derive test file paths from source file paths:
  - replace the `Sources/mas/` source path folder prefix with `Tests/MASTests/`
  - prepend `MASTests+` to the source file name
  - e.g., `Sources/mas/X.swift` → `Tests/MASTests/MASTests+X.swift`
- Use force unwrapping (`!` suffix)
