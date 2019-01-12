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

// MARK: - URLSession+Synchronous
extension NetworkSession {
    /// Return data from synchronous URL request
    public func requestSynchronousData(_ request: URLRequest) -> Data? {
        var data: Data?
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: request) { (taskData, _, error) -> Void in
            data = taskData
            if data == nil, let error = error {
                print(error)
            }
            semaphore.signal()
        }
        task.resume()

        _ = semaphore.wait(timeout: .distantFuture)
        return data
    }

    /// Return data synchronous from specified endpoint
    public func requestSynchronousDataWithURLString(_ requestString: String) -> Data? {
        guard let url = URL(string: requestString) else { return nil }
        let request = URLRequest(url: url)
        return requestSynchronousData(request)
    }

    /// Return JSON synchronous from URL request
    public func requestSynchronousJSON(_ request: URLRequest) -> Any? {
        guard let data = requestSynchronousData(request) else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            printError("\(error.localizedDescription)")
            return nil
        }
    }

    /// Return JSON synchronous from specified endpoint
    public func requestSynchronousJSONWithURLString(_ requestString: String) -> Any? {
        guard let url = URL(string: requestString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return requestSynchronousJSON(request)
    }
}
