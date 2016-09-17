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
    public static func requestSynchronousData(_ request: URLRequest) -> Data? {
        var data: Data? = nil
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            semaphore.signal();
        })
        task.resume()
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return data
    }
    
    /// Return data synchronous from specified endpoint
    public static func requestSynchronousDataWithURLString(_ requestString: String) -> Data? {
        guard let url = URL(string:requestString) else {return nil}
        let request = URLRequest(url: url)
        return URLSession.requestSynchronousData(request)
    }
    
    /// Return JSON synchronous from URL request
    public static func requestSynchronousJSON(_ request: URLRequest) -> AnyObject? {
        guard let data = URLSession.requestSynchronousData(request) else {return nil}
        return try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject?
    }
    
    /// Return JSON synchronous from specified endpoint
    public static func requestSynchronousJSONWithURLString(_ requestString: String) -> AnyObject? {
        guard let url = URL(string: requestString) else {return nil}
        let request = NSMutableURLRequest(url:url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return URLSession.requestSynchronousJSON(request as URLRequest)
    }
}

public extension String {
    
    /// Return an URL encoded string
    func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    }
}

