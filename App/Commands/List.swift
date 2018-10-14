//
//  List.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

public struct ListCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "list"
    public let function = "Lists apps from the Mac App Store which are currently installed"

    public init() {}

    public func run(_ options: Options) -> Result<(), MASError> {
        let softwareMap = CKSoftwareMap.shared()
        guard let products = softwareMap.allProducts() else {
            print("No installed apps found")
            return .success(())
        }
        for product in products {
            print("\(product.itemIdentifier) \(product.appName) (\(product.bundleVersion))")
        }
        return .success(())
    }
}
