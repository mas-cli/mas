//
//  List.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct ListCommand: CommandType {
    let verb = "list"
    let function = "Lists apps from the Mac App Store which are currently installed"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let softwareMap = CKSoftwareMap.sharedSoftwareMap()
            let products = softwareMap.allProducts() as! [CKSoftwareProduct]
            for product in products {
                print("\(product.itemIdentifier) \(product.appName)")
            }
            
        default:
            break
        }
        return .Success(())
    }
}