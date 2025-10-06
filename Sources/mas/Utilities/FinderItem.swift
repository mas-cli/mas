//
// FinderItem.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ScriptingBridge

@objc
protocol FinderItem {
	@objc
	optional var URL: String { get }

	@objc
	optional func delete() -> SBObject
}

extension SBObject: FinderItem {}
