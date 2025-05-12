brew "git"
brew "markdownlint-cli2"
brew "shellcheck"
brew "swiftformat"
brew "swiftlint"
brew "yamllint"

if OS.mac?
	if MacOS.version == :ventura
		tap "peripheryapp/periphery"
		cask "periphery"
	elsif MacOS.version >= :sonoma
		brew "periphery"
	end
end
