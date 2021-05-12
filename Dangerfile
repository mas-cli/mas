#!/usr/bin/env ruby
#
# Dangerfile
# mas-cli
#
# https://danger.systems/guides/dangerfile.html
#

# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
has_app_changes = !git.modified_files.grep(/Sources/).empty?
has_test_changes = !git.modified_files.grep(/Tests/).empty?

# if has_app_changes && !has_test_changes
#     warn("Tests were not updated", sticky: false)
# end

# Thanks other people!
message(":tada:") if github.pr_author != "phatblat"

# Mainly to encourage writing up some reasoning about the PR, rather than just leaving a title
if github.pr_body.length < 5
    fail ":memo: Please provide a summary in the Pull Request description"
end

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn(":construction: PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn(":dizzy_face: Big PR") if git.lines_of_code > 500

# Don't let testing shortcuts get into main by accident
#fail("fdescribe left in tests") if `grep -r fdescribe Tests/ `.length > 1
#fail("fit left in tests") if `grep -r fit Tests/ `.length > 1
