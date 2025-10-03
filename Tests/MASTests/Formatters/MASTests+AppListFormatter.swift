//
// MASTests+AppListFormatter.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

@testable private import MAS
internal import Testing

private let format = AppListFormatter.format(_:)

@Test
func formatsEmptyAppListAsEmptyString() {
	#expect(consequencesOf(format([])) == Consequences(""))
}

@Test
func formatsSingleInstalledApp() {
	#expect(
		consequencesOf(
			format([InstalledApp(adamID: 12345, bundleID: "", name: "Awesome App", path: "", version: "19.2.1")])
		)
		== Consequences("12345  Awesome App  (19.2.1)") // swiftformat:disable:this indent
	)
}

@Test
func formatsTwoInstalledApps() {
	#expect(
		consequencesOf(
			format(
				[
					InstalledApp(adamID: 12345, bundleID: "", name: "Awesome App", path: "", version: "19.2.1"),
					InstalledApp(adamID: 67890, bundleID: "", name: "Even Better App", path: "", version: "1.2.0"),
				]
			)
		) // swiftformat:disable:next indent
		== Consequences("12345  Awesome App      (19.2.1)\n67890  Even Better App  (1.2.0)")
	)
}
