//
//  Login.swift
//  mas-cli
//
//  Created by Quanlong on 30/01/2016.
//  Copyright (c) 2016 Quanlong. All rights reserved.
//

let kOpenAppStore = "\n" +
"tell application \"App Store\" \n" +
"    activate \n" +
"end tell"

let kLoginScript = "\n" +
"tell application \"System Events\" to tell process \"App Store\" \n" +
"    set value of text field \"Apple ID \" of sheet 1 of window \"App Store\" to \"%@\" \n" +
"    set value of text field \"Password\" of sheet 1 of window \"App Store\" to \"%@\" \n" +
"    click button \"Sign In\" of sheet 1 of window \"App Store\" \n" +
"end tell"

struct LoginCommand: CommandType {
    typealias Options = LoginOptions
    let verb = "login"
    let function = "Log in to MAS"
    
    // mas is not allowed assistive access.
    // brew install tccutil
    // sudo /usr/local/bin/tccutil -i com.mphys.mas-cli
    func ensureAccessibilityIsEnabled() -> Bool {
        let key: String = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true]
        
        let enabled = AXIsProcessTrustedWithOptions(options)
        
        return enabled
    }

    func runAppleScript(source: String) -> Bool {
        guard let script = NSAppleScript(source: source) else {
            print("error: invalid script")
            return false
        }
            
        var error: NSDictionary?
        guard script.compileAndReturnError(&error) else {
            print("error: failed to compiled Apple Script: \(error) \(script.source)")
            return false
        }
            
        guard let output: NSAppleEventDescriptor = script.executeAndReturnError(&error) where error == nil else {
            print("error: failed to invoke Apple Script: \(error)")
            return false
        }
            
        print("Executed script: \(output)")
        return true
    }
    
    // Login with Apple Script
    func login(appleId: String, password: String) -> Bool {
        guard runAppleScript(String(format: kLoginScript, appleId, password)) else {
            print("error: failed run login script")
            return false
        }
        
        return true
    }
    
    func openAppStore() -> Bool {
        guard runAppleScript(kOpenAppStore) else {
            print("error: failed run openAppStore script")
            return false
        }
            
        return true
    }
    
    func waitUntilPrimaryAccountIsPresentAndSignedIn() {
        
        while (!ISStoreAccount.primaryAccountIsPresentAndSignedIn) {
            sleep(1)
        }
        
        print("loged in: \(ISStoreAccount.primaryAccount!.identifier)")
    }
    
    func run(options: Options) -> Result<(), MASError> {
        #if DEBUG
            CKAccountStore.sharedAccountStore().signOut()
        #endif

        guard ISStoreAccount.primaryAccount == nil else {
            print("Already signed in with \(ISStoreAccount.primaryAccount!.identifier)")
            exit(MASErrorCode.AlreadySignedIn.exitCode)
        }
            
        guard ensureAccessibilityIsEnabled() else {
            print("Accessibility is not enabled")
            exit(MASErrorCode.NoAccessibilityPermission.exitCode)
        }
        
        // Open App Store
        sleep(1)
        guard openAppStore() else {
            exit(MASErrorCode.SignInError.exitCode)
        }
            
        // Trigger login window
        CKAccountStore.sharedAccountStore().signIn()
        
        // Login
        sleep(1)
        guard login(options.appleId, password: options.password) else {
            exit(MASErrorCode.SignInError.exitCode)
        }

        waitUntilPrimaryAccountIsPresentAndSignedIn()
        
        return .Success(())
    }
}

struct LoginOptions: OptionsType {
    let appleId: String
    let password: String
    
    static func create(appleId: String)(password: String) -> LoginOptions {
        return LoginOptions(appleId: appleId, password: password)
    }
    
    static func evaluate(m: CommandMode) -> Result<LoginOptions, CommandantError<MASError>> {
        return create
            <*> m <| Option(key: "appleId", usage: "the Apple ID to login")
            <*> m <| Option(key: "password", usage: "the password of Apple ID")
    }
}
