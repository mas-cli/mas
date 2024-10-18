brew "markdownlint-cli"
brew "shellcheck"
brew "shfmt"
brew "swift-format"
brew "swiftformat"
brew "trash"

# Already installed on GitHub Actions runner.
# brew "swiftlint"

tap "peripheryapp/periphery"
if OS.mac? && MacOS.version >= :ventura
  cask "periphery"
end
