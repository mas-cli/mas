import Danger

let danger = Danger()

if let github = danger.github {
    // Thank non-member submitters
    let submitter = github.pullRequest.user.login
    switch submitter {
    case "chris-araman",
        "phatblat":
        break
    default:
        danger.message(":tada: Thanks for your contribution, \(submitter)!")
    }

    // Encourage writing up some reasoning about the PR
    if github.pullRequest.body?.count ?? 0 < 5 {
        danger.fail(":memo: Please provide a summary in the Pull Request description.")
    }

    // Warn that PR marked [WIP] should be a Draft
    if github.pullRequest.title.contains("[WIP]") {
        danger.warn(":construction: Title includes `[WIP]`. Please convert the pull request to a Draft.")
    }
}
