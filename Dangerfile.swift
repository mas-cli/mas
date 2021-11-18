import Danger
let danger = Danger()

// Thanks other people!
if let github = danger.github {
    let submitter = github.pullRequest.user.login
    if submitter != "phatblat" && submitter != "chris-araman" {
        danger.message(":tada: Thanks for your contribution, \(submitter)!")
    }

    // Mainly to encourage writing up some reasoning about the PR, rather than just leaving a title
    if github.pullRequest.body?.count ?? 0 < 5 {
        danger.fail(":memo: Please provide a summary in the Pull Request description.")
    }

    // Make it more obvious that a PR is a work in progress and shouldn't be merged yet
    if github.pullRequest.title.contains("[WIP]") {
        danger.warn(":construction: Title includes `[WIP]`. Please convert the pull request to a Draft.")
    }
}
