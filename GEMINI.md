# Gemini Guidelines for `mas`

You are an expert Swift and Zsh developer assisting with the maintenance and
development of `mas`, a command-line interface for the Mac App Store.

## Project Overview

- **Name:** `mas`
- **Description:** A CLI for the Mac App Store, designed for scripting &
  automation.
- **Language:** Swift 6.2 (using Swift Argument Parser)
- **Target OS:** macOS 13+
- **Project Type:** SwiftPM project

## Technical Stack

- **Swift:** 6.2+ (Check [.swift-version](.swift-version))
- **Xcode:** 26+ (Check [.xcode-version](.xcode-version))
- **macOS:** 13+ (Check [Package.swift](Package.swift))
- **Private Frameworks:** Uses `CommerceKit` and `StoreFoundation` for App Store
  integration only where public APIs are insufficient.

## Development Workflows

### Bootstrap

```shell
Scripts/bootstrap
```

### Build

- Debug: `Scripts/build`
- Release: `Scripts/build '' -c release`

### Lint & Format

- Quick Lint: `Scripts/lint -AP`
- Full Lint: `Scripts/lint`
- Format: `Scripts/format` (Run repeatedly until no changes occur)

### Test

```shell
Scripts/test
```

## Engineering Standards

Refer to [AGENTS.md](AGENTS.md) for comprehensive guidelines. Key highlights:

### Content Guidelines

- **Newlines:** UNIX (LF)
- **Indentation:** Tabs (width: 2) for Swift/Zsh; Spaces (2) for YAML; Spaces
  (1) for Markdown.
- **Max line length:** 120 characters (80 for Markdown).
- **Preservation:** Do not reformat, rename, or reorder code unless necessary
  for functionality.

### Markdown Guidelines

- **Style:** ATX headings, fenced code blocks with backticks, underscore
  emphasis, asterisk strong.
- **Language:** Only `console` and `shell` are allowed in code fences.
- **HTML:** Limited to `<details>`, `<h1>`, `<summary>`.

### YAML Guidelines

- **Style:** 2-space indentation, unix newlines, quoted strings only when
  necessary, single quotes for strings.
- **Rules:** Forbid non-empty braces, require document start (`---`).

### Zsh Scripting

- **Shebang:** `#!/bin/zsh -Ndefgku`
- **Setup:** Start scripts with `. "${0:A:h}/_setup_script"`
- **Preference:** Use zsh builtins over external commands.
- **Commands:** Use `cp -c` and `trash` (not `rm`).

### Swift Development

- **Structure:** Organized by `AppStore/`, `Commands/`, `Models/`, `Utilities/`.
- **Force Unwrapping:** Avoid in `Sources/mas/`.
- **Naming:** Capitalize acronyms consistently (e.g., `ADAM`, `API`, `JSON`).
- **Organization:** Group computed properties below stored properties.
- **Error Handling:** Prefer typed throws (`throws(ErrorType)`),
  then `rethrows`, then untyped `throws`.

### Git Workflow

- **Trunk:** `main`
- **Commits:** Follow [conventional commit style](
    https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  ).
- **Pre-commit:** Always run `Scripts/format` and `Scripts/lint` before
  committing.

## Testing Requirements

- **Framework:** [Swift Testing](https://github.com/swiftlang/swift-testing).
- **Location:** `Tests/MASTests/`
- **Naming Convention:** `Sources/mas/Path/To/File.swift` ->
  `Tests/MASTests/Path/To/MASTests+File.swift`.
- **Assertions:** Use force unwrapping (`!`) in tests if appropriate.
