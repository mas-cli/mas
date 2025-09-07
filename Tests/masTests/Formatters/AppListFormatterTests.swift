//
// AppListFormatterTests.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

private let format = AppListFormatter.format(_:)

@Test
func formatsEmptyAppListAsEmptyString() {
	#expect(consequencesOf(format([])) == ValuedConsequences(""))
}

@Test
func formatsSingleInstalledApp() {
	#expect(
		consequencesOf(format([InstalledApp(id: 12345, bundleID: "", name: "Awesome App", path: "", version: "19.2.1")]))
		== ValuedConsequences("12345       Awesome App  (19.2.1)") // swiftformat:disable:this indent
	)
}

@Test
func formatsTwoInstalledApps() {
	#expect(
		consequencesOf(
			format(
				[
					InstalledApp(id: 12345, bundleID: "", name: "Awesome App", path: "", version: "19.2.1"),
					InstalledApp(id: 67890, bundleID: "", name: "Even Better App", path: "", version: "1.2.0"),
				]
			)
		) // swiftformat:disable:next indent
		== ValuedConsequences("12345       Awesome App      (19.2.1)\n67890       Even Better App  (1.2.0)")
	)
}
