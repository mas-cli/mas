//
//  Error.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

public enum MASError: Equatable {
    public var description: String {
        return ""
    }
}

public func == (lhs: MASError, rhs: MASError) -> Bool {
    return false
}