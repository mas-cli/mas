//
// MASTests+Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private let adamID = 12345 as ADAMID
private let app = InstalledApp(
	adamID: adamID,
	bundleID: "com.some.app",
	name: "Some App",
	path: "/tmp/Some.app",
	version: "1.0"
)

extension MASTests {
	@Test(.disabled())
	static func uninstallDryRunCannotRemoveMissingApp() {
		let actual = consequencesOf(try MAS.Uninstall.parse(["--dry-run", String(adamID)]).run(installedApps: []))
		let expected = Consequences(nil, "No installed apps with ADAM ID \(adamID)")
		#expect(actual == expected)
	}

	@Test(.disabled())
	static func uninstallDryRunFindsApp() {
		let actual = consequencesOf(try MAS.Uninstall.parse(["--dry-run", String(adamID)]).run(installedApps: [app]))
		let expected = Consequences(nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n")
		#expect(actual == expected)
	}

	@Test(.disabled())
	static func uninstallCannotRemoveMissingApp() {
		let actual = consequencesOf(try MAS.Uninstall.parse([String(adamID)]).run(installedApps: []))
		let expected = Consequences(nil, "No installed apps with ADAM ID \(adamID)")
		#expect(actual == expected)
	}

	@Test(.disabled())
	static func uninstallRemovesApp() {
		let actual = consequencesOf(try MAS.Uninstall.parse([String(adamID)]).run(installedApps: [app]))
		let expected = Consequences()
		#expect(actual == expected)
	}
}
