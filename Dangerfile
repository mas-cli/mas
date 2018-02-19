# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
has_app_changes = !git.modified_files.grep(/App/).empty?
# has_test_changes = !git.modified_files.grep(/AppTests/).empty?

is_version_bump = git.modified_files.sort == [
    "App/mas-cli-Info.plist",
    "AppTests/Info.plist",
    "CHANGELOG.md",
    "mas-cli.xcodeproj/project.pbxproj"
].sort
message(":bookmark: Version bump!") if is_version_bump

# if has_app_changes && !has_test_changes && !is_version_bump
#     warn("Tests were not updated", sticky: false)
# end

# Thanks other people!
message(":tada:") if is_version_bump && github.pr_author != "phatblat"

# Mainly to encourage writing up some reasoning about the PR, rather than just leaving a title
if github.pr_body.length < 5
    fail ":memo: Please provide a summary in the Pull Request description"
end

# Let people say that this isn't worth a CHANGELOG entry in the PR if they choose
declared_trivial = (github.pr_title + github.pr_body).include?("#trivial") || !has_app_changes
message("This PR might seem trivial, but every contribution counts. :kissing_heart:") if declared_trivial

# Keep the CHANGELOG up-to-date
if !git.modified_files.include?("CHANGELOG.md") && !declared_trivial
    fail(":memo: Please include a CHANGELOG entry. \nYou can find it at [CHANGELOG.md](https://github.com/mas-cli/mas/blob/master/CHANGELOG.md).", sticky: false)
end

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn(":construction: PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn(":dizzy_face: Big PR") if git.lines_of_code > 500

# Don't let testing shortcuts get into master by accident
#fail("fdescribe left in tests") if `grep -r fdescribe Tests/ `.length > 1
#fail("fit left in tests") if `grep -r fit Tests/ `.length > 1
