//
// Required.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

@propertyWrapper
struct Required<Value> {
	let wrappedValue: Value

	init(_ value: @autoclosure () -> Value?, file: StaticString = #file, line: UInt = #line) {
		wrappedValue = value() ?? { preconditionFailure("Required value was nil", file: file, line: line) }()
	}
}

extension Required: Sendable where Value: Sendable {}
