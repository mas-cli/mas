//
// MASTests+Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

private let adamID = 12345 as ADAMID
private let app = InstalledApp(
	adamID: adamID,
	bundleID: "com.some.app",
	name: "Some App",
	path: "/tmp/Some.app",
	version: "1.0"
)

@Test(.disabled())
func uninstallDryRunCannotRemoveMissingApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse(["--dry-run", String(adamID)]).run(installedApps: []))
		== Consequences(nil, "No installed apps with ADAM ID \(adamID)") // swiftformat:disable:this indent
	)
}

@Test(.disabled())
func uninstallDryRunFindsApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse(["--dry-run", String(adamID)]).run(installedApps: [app]))
		== Consequences(nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n")
	) // swiftformat:disable:previous indent
}

@Test(.disabled())
func uninstallCannotRemoveMissingApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse([String(adamID)]).run(installedApps: []))
		== Consequences(nil, "No installed apps with ADAM ID \(adamID)") // swiftformat:disable:this indent
	)
}

@Test(.disabled())
func uninstallRemovesApp() {
	#expect(
		consequencesOf(try MAS.Uninstall.parse([String(adamID)]).run(installedApps: [app])) == Consequences()
	)
}
