//
// UninstallTests.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private let appID = 12345 as AppID
private let app = InstalledApp(
	id: appID,
	bundleID: "com.some.app",
	name: "Some App",
	path: "/tmp/Some.app",
	version: "1.0"
)

@Test(.disabled())
func uninstallDryRunCannotRemoveMissingApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse(["--dry-run", String(appID)]).run(installedApps: []))
		== UnvaluedConsequences(nil, "No installed apps with app ID \(appID)") // swiftformat:disable:this indent
	)
}

@Test(.disabled())
func uninstallDryRunFindsApp() {
	#expect( // swiftformat:disable:next indent
		consequencesOf(try MAS.Uninstall.parse(["--dry-run", String(appID)]).run(installedApps: [app]))
		== UnvaluedConsequences(nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n")
	) // swiftformat:disable:previous indent
}

@Test(.disabled())
func uninstallCannotRemoveMissingApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse([String(appID)]).run(installedApps: []))
		== UnvaluedConsequences(nil, "No installed apps with app ID \(appID)") // swiftformat:disable:this indent
	)
}

@Test(.disabled())
func uninstallRemovesApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse([String(appID)]).run(installedApps: [app])) == UnvaluedConsequences()
	)
}
