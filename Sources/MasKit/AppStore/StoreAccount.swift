//
//  StoreAccount.swift
//  mas-cli
//
//  Created by Ben Chatelain on 4/3/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

import Foundation

protocol StoreAccount {
    var identifier: String { get set }
    var dsID: NSNumber { get set }
}
