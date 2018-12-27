//
//  CKSoftwareMap+AppLookup.swift
//  mas-cli
//
//  Created by Andrew Griffiths on 20/8/17.
//  Copyright © 2017 Andrew Griffiths.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import CommerceKit

private var appIdsByName : [String:UInt64]?

extension CKSoftwareMap {
    func appIdWithProductName(_ name: String) -> UInt64? {
        if appIdsByName == nil {
            let softwareMap = CKSoftwareMap.shared()
            var destMap = [String:UInt64]()
            
            guard let products = softwareMap.allProducts() else {
                return nil
            }
            
            for product in products {
                destMap[product.appName] = product.itemIdentifier.uint64Value
            }
            
            appIdsByName = destMap
        }
        
        return appIdsByName?[name]
    }
}

