//
// IgnoreList.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation

actor IgnoreList {
	static let shared = IgnoreList()

	private var entries = Set<IgnoreEntry>()
	private let fileURL: URL

	private init() {
		let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
		let masDirectory = appSupport.appendingPathComponent("mas", isDirectory: true)
		fileURL = masDirectory.appendingPathComponent("ignore.json")

		try? FileManager.default.createDirectory(at: masDirectory, withIntermediateDirectories: true)

		if let data = try? Data(contentsOf: fileURL) {
			entries = (try? JSONDecoder().decode(Set<IgnoreEntry>.self, from: data)) ?? []
		}
	}

	func add(_ entry: IgnoreEntry) throws {
		entries.insert(entry)
		try save()
	}

	func remove(_ entry: IgnoreEntry) throws {
		entries.remove(entry)
		try save()
	}

	func removeAll(forADAMID adamID: ADAMID) throws {
		entries = entries.filter { $0.adamID != adamID }
		try save()
	}

	func isIgnored(adamID: ADAMID, version: String) -> Bool {
		entries.contains { $0.matches(adamID: adamID, version: version) }
	}

	func isIgnored(adamID: ADAMID) -> Bool {
		entries.contains { $0.adamID == adamID && $0.version == nil }
	}

	func all() -> [IgnoreEntry] {
		Array(entries).sorted { lhs, rhs in
			if lhs.adamID != rhs.adamID {
				return lhs.adamID < rhs.adamID
			}
			guard let lhsVersion = lhs.version, let rhsVersion = rhs.version else {
				return lhs.version == nil
			}

			return lhsVersion < rhsVersion
		}
	}

	func entriesFor(adamID: ADAMID) -> [IgnoreEntry] {
		entries.filter { $0.adamID == adamID }
	}

	func hasAllVersionsIgnore(adamID: ADAMID) -> Bool {
		entries.contains { $0.adamID == adamID && $0.version == nil }
	}

	func hasSpecificVersionIgnores(adamID: ADAMID) -> Bool {
		entries.contains { $0.adamID == adamID && $0.version != nil }
	}

	private func save() throws {
		let data = try JSONEncoder().encode(entries)
		try data.write(to: fileURL, options: .atomic)
	}
}
