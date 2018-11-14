//
//  NSURLSession+Synchronous.swift
//  mas-cli
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

// Synchronous NSURLSession code found at: http://ericasadun.com/2015/11/12/more-bad-things-synchronous-nsurlsessions/

import Foundation

/// NSURLSession synchronous behavior
/// Particularly for playground sessions that need to run sequentially
public extension URLSession {
    /// Return data from synchronous URL request
    // TODO: Unused, remove
    public static func requestSynchronousData(_ request: URLRequest) -> Data? {
        var data: Data? = nil
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            semaphore.signal()
        }
        task.resume()
        let _ = semaphore.wait(timeout: .distantFuture)
        return data
    }

    /// Return data synchronous from specified endpoint
    // TODO: Unused, remove
    public static func requestSynchronousDataWithURLString(_ requestString: String) -> Data? {
        guard let url = URL(string:requestString) else {return nil}
        let request = URLRequest(url: url)
        return URLSession.requestSynchronousData(request)
    }

    /// Return JSON synchronous from URL request
    // TODO: Unused, remove
    public static func requestSynchronousJSON(_ request: URLRequest) -> Any? {
        guard let data = URLSession.requestSynchronousData(request) else {return nil}
        return try! JSONSerialization.jsonObject(with: data, options: [])
    }

    /// Return JSON synchronous from specified endpoint
    public func requestSynchronousJSONWithURLString(_ requestString: String) -> Any? {
        guard let url = URL(string: requestString) else {return nil}
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.requestSynchronousJSON(request)
    }
}

public extension String {
    /// Return an URL encoded string
    var URLEncodedString: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
