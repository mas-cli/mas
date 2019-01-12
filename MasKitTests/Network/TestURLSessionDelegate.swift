//
//  TestURLSessionDelegate.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Delegate for network requests initiated from tests.
class TestURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: (URLSession.AuthChallengeDisposition,
                    URLCredential?) -> Void) {

        // For example, you may want to override this to accept some self-signed certs here.
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust &&
            Constants.selfSignedHosts.contains(challenge.protectionSpace.host) {
            // Allow the self-signed cert.
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            // You *have* to call completionHandler, so call
            // it to do the default action.
            completionHandler(.performDefaultHandling, nil)
        }
    }

    struct Constants {
        // A list of hosts you allow self-signed certificates on.
        // You'd likely have your dev/test servers here.
        // Please don't put your production server here!
        static let selfSignedHosts: Set<String> =
            ["dev.example.com", "test.example.com"]
    }
}
