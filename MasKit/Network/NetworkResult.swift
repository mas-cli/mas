//
//  NetworkResult.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

enum NetworkResult {
    case success(Data)
    case failure(Error)
}

extension NetworkResult: Equatable {
    static func == (lhs: NetworkResult, rhs: NetworkResult) -> Bool {
        switch (lhs, rhs) {
        case let (.success(data1), .success(data2)):
            return data1 == data2

        case let (.failure(error1), .failure(error2)):
            return error1.localizedDescription == error2.localizedDescription

        default:
            return false
        }
    }
}
