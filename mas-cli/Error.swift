//
//  Error.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

public let MASErrorDomain: String = "MASErrorDomain"

private let MASErrorSource: String = "MASErrorSource"

public enum MASErrorCode: Int {
    case noError
    case notSignedIn
    case purchaseError
    case noDownloads
    case cancelled
    case downloadFailed
    case signInError
    case alreadySignedIn
    case searchError
    case noSearchResultsFound
    case noUpdatesFound
    
    var exitCode: Int32 {
        return Int32(self.rawValue)
    }
}

public struct MASError: Error {
    let code: MASErrorCode
    
    let sourceError: NSError?
    
    init(code: MASErrorCode, sourceError: NSError? = nil) {
        self.code = code
        self.sourceError = sourceError
    }
}

public func == (lhs: MASError, rhs: MASError) -> Bool {
    return false
}
