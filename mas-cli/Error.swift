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
    case NoError
    case NotSignedIn
    case PurchaseError
    case NoDownloads
    case Cancelled
    case DownloadFailed
    
    var exitCode: Int32 {
        return Int32(self.rawValue)
    }
}

public class MASError: NSError {
    var masCode: MASErrorCode? {
        return MASErrorCode(rawValue: code)
    }
    
    convenience init(code: MASErrorCode, sourceError: NSError? = nil) {
        var userInfo: [NSObject: AnyObject] = [:]
        if let error = sourceError {
            userInfo[MASErrorSource] = error
        }
        self.init(domain: MASErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

public func == (lhs: MASError, rhs: MASError) -> Bool {
    return false
}