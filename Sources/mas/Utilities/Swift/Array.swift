//
// Array.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

extension Array {
	init(reservedCapacity: Int) {
		self.init()
		reserveCapacity(reservedCapacity)
	}
}
