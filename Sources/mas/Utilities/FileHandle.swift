//
// FileHandle.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Darwin
internal import Foundation

extension FileHandle {
	var isTerminal: Bool {
		isatty(fileDescriptor) != 0
	}
}
