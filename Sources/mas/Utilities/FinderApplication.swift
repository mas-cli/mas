//
// FinderApplication.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ScriptingBridge

@objc
protocol FinderApplication {
	@objc
	optional func items() -> SBElementArray
}

extension SBApplication: FinderApplication {}
