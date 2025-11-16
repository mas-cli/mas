//
// MASTests+Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	func uninstallDryRunCannotRemoveMissingApp() {
		let actual = consequencesOf(
			try MAS.main(try MAS.Uninstall.parse(["--dry-run", String(adamID)])) { try $0.run(installedApps: []) }
		)
		let expected = Consequences(nil, "", "Error: No installed apps with ADAM ID \(adamID)")
		#expect(actual == expected)
	}

	@Test(.disabled())
	func uninstallDryRunFindsApp() {
		let actual = consequencesOf(
			try MAS.main(try MAS.Uninstall.parse(["--dry-run", String(adamID)])) { try $0.run(installedApps: [app]) }
		)
		let expected = Consequences(nil, "==> Dry run. A wet run would uninstall:\n\n/Applications/Some.app\n")
		#expect(actual == expected)
	}

	@Test(.disabled())
	func uninstallCannotRemoveMissingApp() {
		let actual =
			consequencesOf(try MAS.main(try MAS.Uninstall.parse([String(adamID)])) { try $0.run(installedApps: []) })
		let expected = Consequences(nil, "", "Error: No installed apps with ADAM ID \(adamID)")
		#expect(actual == expected)
	}

	@Test(.disabled())
	func uninstallRemovesApp() {
		let actual =
			consequencesOf(try MAS.main(try MAS.Uninstall.parse([String(adamID)])) { try $0.run(installedApps: [app]) })
		let expected = Consequences()
		#expect(actual == expected)
	}
}

private let adamID = 12345 as ADAMID
private let app = InstalledApp(
	adamID: adamID,
	bundleID: "com.some.app",
	name: "Some App",
	path: "/Applications/Some.app",
	version: "1.0"
)
