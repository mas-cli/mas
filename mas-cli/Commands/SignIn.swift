//
//  SignIn.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct SignInCommand: CommandType {
    typealias Options = SignInOptions
    let verb = "signin"
    let function = "Sign in to the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        
        guard ISStoreAccount.primaryAccount == nil else {
            return .failure(MASError.init(code: .alreadySignedIn))
        }
        
        do {
            print("==> Signing in to Apple ID: \(options.username)")
            
            let password: String = {
                if options.password == "" && !options.dialog {
                    return String(validatingUTF8: getpass("Password: "))!
                }
                return options.password
            }()

            let _ = try ISStoreAccount.signIn(username: options.username, password: password, systemDialog: options.dialog)
        } catch let error as NSError {
            return .failure(MASError(code: .signInError, sourceError: error))
        }
        
        return .success(())
    }
}

struct SignInOptions: OptionsType {
    let username: String
    let password: String
    
    let dialog:   Bool
    
    typealias ClientError = MASError
    
    static func create(username: String) -> (_ password: String) -> (_ dialog: Bool) -> SignInOptions {
        return { password in { dialog in
            return SignInOptions(username: username, password: password, dialog: dialog)
        }}
    }
    
    static func evaluate(_ m: CommandMode) -> Result<SignInOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "Apple ID")
            <*> m <| Argument(defaultValue: "", usage: "Password")
            <*> m <| Option(key: "dialog", defaultValue: false, usage: "Complete login with graphical dialog")
    }
}
