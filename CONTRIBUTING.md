# Contributing

We love pull requests from everyone. By participating in this project, you agree to abide by our [code of conduct](CODE_OF_CONDUCT.md).

## Getting Started

- Make sure you have a [GitHub account](https://github.com/join).
- [Open an issue](https://github.com/mas-cli/mas/issues/new) to simply ask a question or request a new feature.
- Search for similar issues with the
[ERROR MESSAGE](https://github.com/mas-cli/mas/issues?utf8=%E2%9C%93&q=is%3Aopen+ERROR+MESSAGE)
you are exeriencing.
- If one doesn't exist, [open a new issue](https://github.com/mas-cli/mas/issues/new)
  - Clearly describe the issue including steps to reproduce when it is a bug.
  - Include the earliest version of `mas` that you know has the issue.
  - Include your macOS version.

## Making Changes

- [Fork the repository](https://github.com/mas-cli/mas#fork-destination-box) on GitHub.
- Cone your fork
  `git clone git@github.com:your-username/mas.git`
- Create a topic branch from where you want to base your work.
  - This is usually the `master` branch.
  - To quickly create a topic branch based on `master`, run
     `git checkout -b awesome-feature master`
  - Please avoid working [directly on the master branch](https://softwareengineering.stackexchange.com/questions/223400/when-should-i-stop-committing-to-master-on-new-projects).
  - Make commits of logical units.
- Run script/format before committing your changes. Fix anything that isn't automatically fixed by the linters.
- Push your topic branch to your fork and [submit a pull request](https://github.com/mas-cli/mas/compare/master...your-username:topic-branch).

Some things that will increase the chance that your pull request is accepted:

- Write tests. (Tests target is still [in progress](https://github.com/mas-cli/mas/issues/123))
  - If you need help with tests, feel free to open a PR in the meantime and just ask for some help.
  - Add "[WIP]" to the title of your PR to indicate that it's not ready to be merged.
- Follow our [style guide](docs/style.md).
- Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
  - Including [appropriate emoji](https://gitmoji.carloscuesta.me/) in the first line of commit messages is fun :wink:.

## Becoming a Contributor

Once you have had a few PRs accepted, if you are interested in joining the
[@mas-cli/contributors](https://github.com/orgs/mas-cli/teams/contributors)
team to help with the issue/PR backlog and even release new versions of this project,
[open a new issue](https://github.com/mas-cli/mas/issues/new)
titled "Add Contributor: @YourGitHubUsername", with a brief message asking to join the team.

This project was created by [@argon](https://github.com/argon), who is unable to continue contributing
to this project, but must remain an owner. By becoming a contributor, you agree to the terms in [#47](https://github.com/mas-cli/mas/issues/47).

## Branching and Releases

- This project follows [trunk-based development](https://trunkbaseddevelopment.com/), where `master` is our trunk.
- Release commits will be tagged in the format: `v1.2.3`.
- Once releases are tagged, high-level release notes are published on the
[releases](https://github.com/mas-cli/mas/releases) page.

See GitHub's post on creating [Contributing Guidelines](https://github.com/blog/1184-contributing-guidelines)
if you would like to set up something like this for your projects.
