//
//  StoreAccount.swift
//  mas-cli
//
//  Created by Ben Chatelain on 4/3/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

protocol StoreAccount {
    static var primaryAccountIsPresentAndSignedIn: Bool { get }
    static var primaryAccount: StoreAccount? { get }
    static func signIn(username: String?, password: String?, systemDialog: Bool) throws -> StoreAccount

    var identifier: String! { get set }
}
