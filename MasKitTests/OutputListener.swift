//
//  OutputListener.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/7/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Test helper for monitoring strings written to stdout. Modified from:
/// https://medium.com/@thesaadismail/eavesdropping-on-swifts-print-statements-57f0215efb42
class OutputListener {
    /// consumes the messages on STDOUT
    let inputPipe = Pipe()

    /// outputs messages back to STDOUT
    let outputPipe = Pipe()

    /// Buffers strings written to stdout
    var contents = ""

    init() {
        // Set up a read handler which fires when data is written to our inputPipe
        inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            strongify(self) { context in
                let data = fileHandle.availableData
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    context.contents += string
                }

                // Write input back to stdout
                context.outputPipe.fileHandleForWriting.write(data)
            }
        }
    }
}

extension OutputListener {
    /// Sets up the "tee" of piped output, intercepting stdout then passing it through.
    ///
    /// ## [dup2 documentation](https://linux.die.net/man/2/dup2)
    /// `int dup2(int oldfd, int newfd);`
    /// `dup2()` makes `newfd` be the copy of `oldfd`, closing `newfd` first if necessary.
    func openConsolePipe() {
        var dupStatus: Int32

        // Copy STDOUT file descriptor to outputPipe for writing strings back to STDOUT
        dupStatus = dup2(stdoutFileDescriptor, outputPipe.fileHandleForWriting.fileDescriptor)
        // Status should equal newfd
        assert(dupStatus == outputPipe.fileHandleForWriting.fileDescriptor)

        // Intercept STDOUT with inputPipe
        // newFileDescriptor is the pipe's file descriptor and the old file descriptor is STDOUT_FILENO
        dupStatus = dup2(inputPipe.fileHandleForWriting.fileDescriptor, stdoutFileDescriptor)
        // Status should equal newfd
        assert(dupStatus == stdoutFileDescriptor)

        // Don't have any tests on stderr yet
        // dup2(inputPipe.fileHandleForWriting.fileDescriptor, stderr)
    }

    /// Tears down the "tee" of piped output.
    func closeConsolePipe() {
        // Restore stdout
        freopen("/dev/stdout", "a", stdout)

        [inputPipe.fileHandleForReading, outputPipe.fileHandleForWriting]
            .forEach { file in
                file.closeFile()
            }
    }
}

extension OutputListener {
    /// File descriptor for stdout (aka STDOUT_FILENO)
    var stdoutFileDescriptor: Int32 {
        return FileHandle.standardOutput.fileDescriptor
    }

    /// File descriptor for stderr (aka STDERR_FILENO)
    var stderrFileDescriptor: Int32 {
        return FileHandle.standardError.fileDescriptor
    }
}
