//
// MASTests+MAS.List.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func `lists apps`() {
		let actual = consequencesOf(try MAS.main(try MAS.List.parse(.init())) { $0.run(installedApps: .init()) })
		let expected = Consequences(
			nil,
			"", // editorconfig-checker-disable
			"""
			Warning: No installed apps found

			         If this is unexpected, index apps in Spotlight (which might take some time):

			         # Individual app (if the omitted apps are known). e.g., for Xcode:
			         mdimport /Applications/Xcode.app

			         # All apps:
			         vol="$(/usr/libexec/PlistBuddy -c "Print :PreferredVolume:name" ~/Library/Preferences/com.apple.appstored.plist 2>/dev/null)"
			         mdimport /Applications ${vol:+"/Volumes/${vol}/Applications"}

			         # All volumes:
			         sudo mdutil -Eai on

			""", // editorconfig-checker-enable
		)
		#expect(actual == expected)
	}
}
