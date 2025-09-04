brew "git"               # 2.51.0
brew "markdownlint-cli2" # 0.18.1
brew "shellcheck"        # 0.11.0
brew "swiftformat"       # 0.57.2
brew "swiftlint"         # 0.60.0
brew "yamllint"          # 1.37.1

if OS.mac?
	if MacOS.version == :ventura
		tap "peripheryapp/periphery"
		cask "periphery"     # 2.21.2
	elsif MacOS.version >= :sonoma
		brew "periphery"     # 3.2.0
	end
end
