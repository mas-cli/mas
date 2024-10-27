//
//  StoreAccount.swift
//  mas
//
//  Created by Ben Chatelain on 4/3/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

import Foundation

// periphery:ignore - save for future use in testing
protocol StoreAccount {
    var identifier: String { get set }
    var dsID: NSNumber { get set }
}
