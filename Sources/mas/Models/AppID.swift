//
//  AppID.swift
//  mas
//
//  Created by Ross Goldberg on 2024-10-29.
//  Copyright © 2024 mas-cli. All rights reserved.
//

typealias AppID = UInt64

extension AppID {
	var unknownMessage: String {
		"Unknown app ID \(self)"
	}
}
