# Contributing

Pull requests (PRs) are welcome from everyone.

By participating in this project, you agree to abide by the
[code of conduct](CODE_OF_CONDUCT.md).

## Getting Started

- Ensure you have a [GitHub account](https://github.com/signup)
- [Search for similar issues](https://github.com/mas-cli/mas/issues)
- If one doesn't exist,
  [open a new issue](https://github.com/mas-cli/mas/issues/new/choose)
  - Select the appropriate issue template
  - Follow the instructions in the issue template

## Making Changes

This project uses [trunk-based development](https://trunkbaseddevelopment.com),
where `main` is the trunk.

- [Fork the repository](https://github.com/mas-cli/mas#fork-destination-box) on
  GitHub
- Clone your fork: `git clone git@github.com:your-username/mas.git`
- Create a topic branch instead of [working directly on `main`](
    https://softwareengineering.stackexchange.com/questions/223400
  )
  - To branch a topic branch from `main` named, e.g., `feature`, run:
    `git checkout -b feature main`
- Commit logical units
- Follow the [style guide](Documentation/style.md)
- Run `Scripts/format` before committing
- Run `Scripts/lint` before committing, then fix all lint violations
- Write tests
  - If you need help with tests, feel free to open a PR, then ask for help
- Write [good commit messages](
    https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  )
- Push your topic branch to your fork, then submit a pull request (PR)
  - If your PR is not ready to be merged, create a draft PR

## Releases

- Release commits are tagged in the format of `v1.2.3`
- Releases (including release notes) are published on the
  [Releases page](https://github.com/mas-cli/mas/releases)

## Becoming a Contributor

To join the [team](https://github.com/orgs/mas-cli/teams/contributors), once a
few of your PRs have been accepted,
[open an issue](https://github.com/mas-cli/mas/issues/new) titled
"Add Contributor: @YourGitHubUsername".

This project was created by [@argon](https://github.com/argon), who is unable to
continue contributing to this project, but must remain an owner.

By becoming a contributor, you agree to the following terms:

- Do not claim to be the original author
- Retain [@argon](https://github.com/argon)'s name in the license; others' names
  may be added to it after they have made substantial contributions
- Retain [@argon](https://github.com/argon)'s name (Andrew Naylor),
  [GitHub account](https://github.com/argon) & [X handle](https://x.com/argon)
  in the [README](README.md), though they may be repositioned as deemed suitable

## Project Lead Responsibilities

Project leads agree to the following terms:

- [@argon](https://github.com/argon) must continue to be one of the organization
  owners
- Project leads have full control, however, over the project's future direction
- If you are the sole project lead, but can no longer lead the project, either:
  - Find someone else to assume the project leadership who agrees to adhere to,
    & propagate, the existing terms
  - If you cannot find a new project lead:
    - Add an [unmaintained badge](https://unmaintained.tech) to the
      [README](README.md)
    - Message [@argon](https://github.com/argon) via [X](https://x.com/argon) or
      [email](mailto:argon@mkbot.net)
    - Transfer the project back to [@argon](https://github.com/argon)
