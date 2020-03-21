# set the number of lines that must be changed before this classifies as a 'Big PR'
@SDM_DANGER_BIG_PR_LINES = 50

# set the files to watch and fail if there are changes
@SDM_DANGER_IMMUTABLE_FILES = ['LICENSE', 'CODE_OF_CONDUCT.md']

# Sometimes it's a README fix, or something like that which is trivial
not_declared_trivial = !(github.pr_title.include? "#trivial")
has_app_changes = git.modified_files.grep(/Sources/).any? { |file| file.end_with?(".swift") || file.end_with?(".h") }
no_test_modify = git.modified_files.grep(/Tests/).empty?

# Warns when changing source files
if has_app_changes && not_declared_trivial && no_test_modify
  warn("Need to add an unit test if you're modifying swift source")
end

# determine if any of the files were modified
def did_modify(files_array)
  did_modify_files = false
  files_array.each do |file_name|
	if git.modified_files.include?(file_name) || git.deleted_files.include?(file_name)
	  did_modify_files = true
	end
  end
  return did_modify_files
end

# Fail if changes to immutable files, such as License or CoC
fail('Do not modify the license or Code of Conduct') if did_modify(@SDM_DANGER_IMMUTABLE_FILES)

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > @SDM_DANGER_BIG_PR_LINES

# Make a note about contributors not in the organization
unless github.api.organization_member?('Quick', github.pr_author)
  # Pay extra attention if they modify the podspec
  if git.modified_files.include?("*.podspec")
    warn "External contributor has edited the Podspec file"
  end
end

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
if github.pr_body.length < 5
  warn "Please provide a summary in the Pull Request description"
end

swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files

