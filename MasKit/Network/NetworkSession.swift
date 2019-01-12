//
//  NetworkSession.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@objc public protocol NetworkSession {
    @objc func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void)
}
