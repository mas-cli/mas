//
// Reset.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

private import AppKit
internal import ArgumentParser
private import CommerceKit
private import Darwin
private import Foundation

extension MAS {
	/// Terminates several macOS processes & deletes files to reset the Mac App
	/// Store.
	struct Reset: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Reset Mac App Store processes"
		)

		/// Runs the command.
		func run() throws {
			try MAS.run { run(printer: $0) }
		}

		/// The "Reset Application" command in the Mac App Store debug menu performs
		/// the following steps:
		///
		/// - `killall Dock`
		/// - `killall storeagent` (`storeagent` no longer exists)
		/// - deletes the `com.apple.appstore` download folder
		/// - clears cookies (appears to be a no-op)
		///
		/// As `storeagent` no longer exists, terminates all processes known to be
		/// associated with the Mac App Store.
		func run(printer: Printer) {
			for bundleID in ["com.apple.dock", "com.apple.storeuid"] {
				for app in NSRunningApplication.runningApplications(withBundleIdentifier: bundleID) where !app.terminate() {
					printer.warning("Failed to terminate app with bundle ID:", bundleID)
					if !app.forceTerminate() {
						printer.error("Failed to force terminate app with bundle ID:", bundleID)
					}
				}
			}

			let executablePathSet = Set([
				"/System/Library/Frameworks/StoreKit.framework/Support/storekitagent",
				"/System/Library/PrivateFrameworks/AppStoreComponents.framework/Support/appstorecomponentsd",
				"/System/Library/PrivateFrameworks/AppStoreDaemon.framework/Support/appstoreagent",
				"""
				/System/Library/PrivateFrameworks/CascadeSets.framework/Versions/A/XPCServices/SetStoreUpdateService.xpc/Contents/MacOS/SetStoreUpdateService
				""",
				"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storeaccountd",
				"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storeassetd",
				"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storedownloadd",
				"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storeinstalld",
				"/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storelegacy",
			])

			var processListMIB = [CTL_KERN, KERN_PROC, KERN_PROC_ALL]
			var length = 0
			guard sysctl(&processListMIB, u_int(processListMIB.count), nil, &length, nil, 0) == 0 else {
				printer.error("Failed to get process list length")
				return
			}

			var kinfoProcs = [kinfo_proc](repeating: kinfo_proc(), count: length / MemoryLayout<kinfo_proc>.stride)
			guard sysctl(&processListMIB, u_int(processListMIB.count), &kinfoProcs, &length, nil, 0) == 0 else {
				printer.error("Failed to get process list")
				return
			}

			var executablePathBuffer = [CChar](repeating: 0, count: Int(PATH_MAX))
			for pid in kinfoProcs.map(\.kp_proc.p_pid) {
				guard
					proc_pidpath(pid, &executablePathBuffer, UInt32(executablePathBuffer.count)) > 0,
					let executablePath = String(cString: executablePathBuffer, encoding: .utf8),
					executablePathSet.contains(executablePath)
				else {
					continue
				}

				let exitStatus = kill(pid, SIGTERM)
				if exitStatus != 0 {
					printer.error("Failed to terminate", executablePath, "getting exit status", exitStatus, "for pid", pid)
				}
			}

			let folder = CKDownloadDirectory(nil)
			do {
				try FileManager.default.removeItem(atPath: folder)
			} catch {
				printer.error("Failed to delete download folder", folder, error: error)
			}
		}
	}
}
