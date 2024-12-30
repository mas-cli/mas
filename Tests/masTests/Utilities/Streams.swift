//
//  Streams.swift
//  masTests
//
//  Created by Ross Goldberg on 2024-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import Foundation

func captureStream(
    _ stream: UnsafeMutablePointer<FILE>,
    encoding: String.Encoding = .utf8,
    _ block: @escaping () throws -> Void
) rethrows -> String {
    let originalFd = fileno(stream)
    let duplicateFd = dup(originalFd)
    defer {
        close(duplicateFd)
    }

    let pipe = Pipe()
    dup2(pipe.fileHandleForWriting.fileDescriptor, originalFd)

    do {
        defer {
            fflush(stream)
            dup2(duplicateFd, originalFd)
            pipe.fileHandleForWriting.closeFile()
        }

        try block()
    }

    return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: encoding) ?? ""
}
