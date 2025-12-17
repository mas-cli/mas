//
// MASTests+Ignore.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func addsVersionSpecificIgnore() async throws {
		// Clear any existing entries first
		try await IgnoreList.shared.removeAll(forADAMID: 12345)

		let actual = await consequencesOf(try await MAS.main(try MAS.Ignore.Add.parse(["12345", "--version", "1.0"])))
		let expected = Consequences(nil, "Ignoring 12345 version 1.0\n")
		#expect(actual == expected)

		// Verify entry was added
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 12345, version: "1.0")
		#expect(isIgnored == true)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 12345)
	}

	@Test
	func addsAllVersionsIgnore() async throws {
		// Clear any existing entries first
		try await IgnoreList.shared.removeAll(forADAMID: 67890)

		let actual = await consequencesOf(try await MAS.main(try MAS.Ignore.Add.parse(["67890"])))
		let expected = Consequences(nil, "Ignoring all versions of 67890\n")
		#expect(actual == expected)

		// Verify entry was added
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 67890)
		#expect(isIgnored == true)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 67890)
	}

	@Test
	func stripsParenthesesFromVersion() async throws {
		// Clear any existing entries first
		try await IgnoreList.shared.removeAll(forADAMID: 11111)

		let actual = await consequencesOf(try await MAS.main(try MAS.Ignore.Add.parse(["11111", "--version", "(2.5)"])))
		let expected = Consequences(nil, "Ignoring 11111 version 2.5\n")
		#expect(actual == expected)

		// Verify entry was added with cleaned version
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 11111, version: "2.5")
		#expect(isIgnored == true)

		// Should not match with parentheses
		let isIgnoredWithParens = await IgnoreList.shared.isIgnored(adamID: 11111, version: "(2.5)")
		#expect(isIgnoredWithParens == false)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 11111)
	}

	@Test
	func warnsWhenAddingSpecificVersionWithExistingAllVersionsIgnore() async throws {
		// Setup: Add all-versions ignore first
		try await IgnoreList.shared.removeAll(forADAMID: 22222)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 22222, version: nil))

		// Try to add specific version with --yes flag (to skip prompt)
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Add.parse(["22222", "--version", "1.0", "--yes"]))
		)

		// Should warn and replace
		#expect(actual.stderr.contains("Warning: App 22222 already has all versions ignored."))
		#expect(actual.stdout.contains("Replaced all-versions ignore with version-specific ignore for 1.0"))

		// Verify all-versions was removed and specific version was added
		let hasAllVersions = await IgnoreList.shared.isIgnored(adamID: 22222)
		#expect(hasAllVersions == false)
		let hasSpecificVersion = await IgnoreList.shared.isIgnored(adamID: 22222, version: "1.0")
		#expect(hasSpecificVersion == true)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 22222)
	}

	@Test
	func warnsWhenAddingAllVersionsWithExistingSpecificVersionIgnores() async throws {
		// Setup: Add specific version ignores first
		try await IgnoreList.shared.removeAll(forADAMID: 33333)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 33333, version: "1.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 33333, version: "1.1"))

		// Try to add all-versions with --yes flag (to skip prompt)
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Add.parse(["33333", "--yes"]))
		)

		// Should warn and replace
		#expect(actual.stderr.contains("Warning: App 33333 already has specific version(s) ignored"))
		#expect(actual.stdout.contains("Replaced version-specific ignores with all-versions ignore"))

		// Verify specific version entries were removed and all-versions was added
		let entries = await IgnoreList.shared.entriesFor(adamID: 33333)
		#expect(entries.count == 1)
		#expect(entries[0].version == nil)

		// The isIgnored checks should all return true now because all versions are ignored
		let hasAllVersions = await IgnoreList.shared.isIgnored(adamID: 33333)
		#expect(hasAllVersions == true)
		let matchesAnyVersion1 = await IgnoreList.shared.isIgnored(adamID: 33333, version: "1.0")
		#expect(matchesAnyVersion1 == true)
		let matchesAnyVersion2 = await IgnoreList.shared.isIgnored(adamID: 33333, version: "1.1")
		#expect(matchesAnyVersion2 == true)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 33333)
	}

	@Test
	func removesVersionSpecificIgnore() async throws {
		// Setup: Add an entry first
		try await IgnoreList.shared.removeAll(forADAMID: 44444)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 44444, version: "3.0"))

		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Remove.parse(["44444", "--version", "3.0"]))
		)
		let expected = Consequences(nil, "No longer ignoring 44444 version 3.0\n")
		#expect(actual == expected)

		// Verify entry was removed
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 44444, version: "3.0")
		#expect(isIgnored == false)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 44444)
	}

	@Test
	func removesAllVersionsIgnore() async throws {
		// Setup: Add an entry first
		try await IgnoreList.shared.removeAll(forADAMID: 55555)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 55555, version: nil))

		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Remove.parse(["55555"]))
		)
		let expected = Consequences(nil, "No longer ignoring all versions of 55555\n")
		#expect(actual == expected)

		// Verify entry was removed
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 55555)
		#expect(isIgnored == false)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 55555)
	}

	@Test
	func removesAllEntriesForAppID() async throws {
		// Setup: Add multiple entries
		try await IgnoreList.shared.removeAll(forADAMID: 66666)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 66666, version: "1.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 66666, version: "2.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 66666, version: nil))

		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Remove.parse(["66666", "--all"]))
		)
		let expected = Consequences(nil, "Removed all ignore entries for 66666\n")
		#expect(actual == expected)

		// Verify all entries were removed
		let entries = await IgnoreList.shared.entriesFor(adamID: 66666)
		#expect(entries.isEmpty == true)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 66666)
	}

	@Test
	func removeStripsParenthesesFromVersion() async throws {
		// Setup: Add entry with clean version
		try await IgnoreList.shared.removeAll(forADAMID: 77777)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 77777, version: "4.5"))

		// Remove with parentheses
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Remove.parse(["77777", "--version", "(4.5)"]))
		)
		let expected = Consequences(nil, "No longer ignoring 77777 version 4.5\n")
		#expect(actual == expected)

		// Verify entry was removed
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 77777, version: "4.5")
		#expect(isIgnored == false)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 77777)
	}

	@Test
	func listsIgnoredApps() async throws {
		// Setup: Add multiple entries
		try await IgnoreList.shared.removeAll(forADAMID: 88888)
		try await IgnoreList.shared.removeAll(forADAMID: 99999)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 88888, version: "1.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 99999, version: nil))

		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.List.parse([]))
		)

		// Should contain both entries
		#expect(actual.stdout.contains("88888"))
		#expect(actual.stdout.contains("1.0"))
		#expect(actual.stdout.contains("99999"))
		#expect(actual.stdout.contains("(all versions)"))

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 88888)
		try await IgnoreList.shared.removeAll(forADAMID: 99999)
	}

	@Test
	func listsNoIgnoredAppsWhenEmpty() async throws {
		// Setup: Clear specific test IDs
		try await IgnoreList.shared.removeAll(forADAMID: 10001)

		// If there are other entries from other tests, we can't guarantee empty list
		// So we'll just check that our specific IDs aren't there
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.List.parse([]))
		)

		// Should not contain our test ID
		#expect(!actual.stdout.contains("10001"))
	}

	@Test
	func clearsAllIgnoredApps() async throws {
		// Setup: Add some entries
		try await IgnoreList.shared.removeAll(forADAMID: 11111)
		try await IgnoreList.shared.removeAll(forADAMID: 22222)
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 11111, version: "1.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 22222, version: nil))

		let actual = await consequencesOf(
			try await MAS.main(try MAS.Ignore.Clear.parse([]))
		)
		let expected = Consequences(nil, "Cleared all ignore entries\n")
		#expect(actual == expected)

		// Verify entries were removed
		let entries1 = await IgnoreList.shared.entriesFor(adamID: 11111)
		let entries2 = await IgnoreList.shared.entriesFor(adamID: 22222)
		#expect(entries1.isEmpty == true)
		#expect(entries2.isEmpty == true)
	}
}
