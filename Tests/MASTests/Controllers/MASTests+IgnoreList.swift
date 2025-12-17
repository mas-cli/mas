//
// MASTests+IgnoreList.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func addsIgnoreEntry() async throws {
		let entry = IgnoreEntry(adamID: 12345, version: "1.0")
		try await IgnoreList.shared.add(entry)

		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 12345, version: "1.0")
		#expect(isIgnored == true)

		// Cleanup
		try await IgnoreList.shared.remove(entry)
	}

	@Test
	func removesIgnoreEntry() async throws {
		let entry = IgnoreEntry(adamID: 23456, version: "2.0")
		try await IgnoreList.shared.add(entry)
		try await IgnoreList.shared.remove(entry)

		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 23456, version: "2.0")
		#expect(isIgnored == false)
	}

	@Test
	func checksIfSpecificVersionIsIgnored() async throws {
		let entry = IgnoreEntry(adamID: 34567, version: "3.0")
		try await IgnoreList.shared.add(entry)

		// Should match exact version
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 34567, version: "3.0")
		#expect(isIgnored == true)

		// Should not match different version
		let isIgnoredDifferent = await IgnoreList.shared.isIgnored(adamID: 34567, version: "4.0")
		#expect(isIgnoredDifferent == false)

		// Cleanup
		try await IgnoreList.shared.remove(entry)
	}

	@Test
	func checksIfAllVersionsAreIgnored() async throws {
		let entry = IgnoreEntry(adamID: 45678, version: nil)
		try await IgnoreList.shared.add(entry)

		// Should match with no version specified
		let isIgnored = await IgnoreList.shared.isIgnored(adamID: 45678)
		#expect(isIgnored == true)

		// Should also match any specific version
		let isIgnoredVersion1 = await IgnoreList.shared.isIgnored(adamID: 45678, version: "1.0")
		#expect(isIgnoredVersion1 == true)
		let isIgnoredVersion2 = await IgnoreList.shared.isIgnored(adamID: 45678, version: "2.0")
		#expect(isIgnoredVersion2 == true)

		// Cleanup
		try await IgnoreList.shared.remove(entry)
	}

	@Test
	func removesAllEntriesForADAMID() async throws {
		let entry1 = IgnoreEntry(adamID: 56789, version: "1.0")
		let entry2 = IgnoreEntry(adamID: 56789, version: "2.0")
		let entry3 = IgnoreEntry(adamID: 56789, version: nil)

		try await IgnoreList.shared.add(entry1)
		try await IgnoreList.shared.add(entry2)
		try await IgnoreList.shared.add(entry3)

		try await IgnoreList.shared.removeAll(forADAMID: 56789)

		let entries = await IgnoreList.shared.entriesFor(adamID: 56789)
		#expect(entries.isEmpty == true)
	}

	@Test
	func getsEntriesForADAMID() async throws {
		let entry1 = IgnoreEntry(adamID: 67890, version: "1.0")
		let entry2 = IgnoreEntry(adamID: 67890, version: "2.0")
		let entry3 = IgnoreEntry(adamID: 78901, version: "1.0")

		try await IgnoreList.shared.add(entry1)
		try await IgnoreList.shared.add(entry2)
		try await IgnoreList.shared.add(entry3)

		let entries = await IgnoreList.shared.entriesFor(adamID: 67890)
		#expect(entries.count == 2)
		#expect(entries.contains(entry1) == true)
		#expect(entries.contains(entry2) == true)
		#expect(entries.contains(entry3) == false)

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 67890)
		try await IgnoreList.shared.removeAll(forADAMID: 78901)
	}

	@Test
	func checksIfHasAllVersionsIgnore() async throws {
		let entry = IgnoreEntry(adamID: 11223, version: nil)
		try await IgnoreList.shared.add(entry)

		let hasAllVersions = await IgnoreList.shared.hasAllVersionsIgnore(adamID: 11223)
		#expect(hasAllVersions == true)

		// Should return false for app with no ignore
		let hasAllVersionsNone = await IgnoreList.shared.hasAllVersionsIgnore(adamID: 99998)
		#expect(hasAllVersionsNone == false)

		// Cleanup
		try await IgnoreList.shared.remove(entry)
	}

	@Test
	func checksIfHasSpecificVersionIgnores() async throws {
		let entry = IgnoreEntry(adamID: 22334, version: "1.0")
		try await IgnoreList.shared.add(entry)

		let hasSpecific = await IgnoreList.shared.hasSpecificVersionIgnores(adamID: 22334)
		#expect(hasSpecific == true)

		// Should return false for app with no ignore
		let hasSpecificNone = await IgnoreList.shared.hasSpecificVersionIgnores(adamID: 99997)
		#expect(hasSpecificNone == false)

		// Cleanup
		try await IgnoreList.shared.remove(entry)
	}

	@Test
	func sortsEntriesCorrectly() async throws {
		// Add entries in random order
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 33445, version: "2.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 33445, version: nil))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 22334, version: "1.0"))
		try await IgnoreList.shared.add(IgnoreEntry(adamID: 33445, version: "1.0"))

		let all = await IgnoreList.shared.all()
		let filtered = all.filter { $0.adamID == 33445 || $0.adamID == 22334 }

		// Should be sorted by adamID first
		#expect(filtered[0].adamID < filtered[1].adamID)

		// Within same adamID, all-versions (nil) should come first
		let adam33445 = filtered.filter { $0.adamID == 33445 }
		#expect(adam33445[0].version == nil)

		// Then version-specific should be sorted alphabetically
		#expect(adam33445[1].version == "1.0")
		#expect(adam33445[2].version == "2.0")

		// Cleanup
		try await IgnoreList.shared.removeAll(forADAMID: 22334)
		try await IgnoreList.shared.removeAll(forADAMID: 33445)
	}
}
