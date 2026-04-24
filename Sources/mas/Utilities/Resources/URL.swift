//
// URL.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import AppKit
private import Foundation
private import ObjectiveC
private import System

extension URL {
	var filePath: String {
		unsafe withUnsafeFileSystemRepresentation { unsafe $0.map(String.init(cString:)) }
		?? .init(path(percentEncoded: false).dropLast { $0 == "/" }) // swiftformat:disable:this indent
	}

	init(folderPath path: String, relativeTo base: URL? = nil) {
		self.init(filePath: path, directoryHint: .isDirectory, relativeTo: base)
	}

	init(nonFolderPath path: String, relativeTo base: URL? = nil) {
		self.init(filePath: path, directoryHint: .notDirectory, relativeTo: base)
	}

	func open(configuration: NSWorkspace.OpenConfiguration = .init()) async throws -> NSRunningApplication {
		try await NSWorkspace.shared.open(self, configuration: configuration)
	}
}
