//
//  Result+Additions.swift
//  Commandant
//
//  Created by Dalton Claybrook on 4/5/19.
//  Copyright © 2019 Carthage. All rights reserved.
//

internal extension Result {
	var value: Success? {
		switch self {
		case .success(let value):
			return value
		case .failure:
			return nil
		}
	}

	var error: Failure? {
		switch self {
		case .success:
			return nil
		case .failure(let error):
			return error
		}
	}
}
