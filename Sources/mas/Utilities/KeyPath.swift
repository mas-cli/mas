//
// KeyPath.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

prefix func ! <Root>(keyPath: KeyPath<Root, Bool>) -> (Root) -> Bool { // swiftlint:disable:this static_operator
	{ !$0[keyPath: keyPath] }
}
