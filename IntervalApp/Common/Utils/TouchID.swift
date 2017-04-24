//
//  TouchID.swift
//  IntervalApp
//
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import LocalAuthentication
import KeychainAccess

final public class TouchID
{
    // TouchID Keys
    static var TouchIDUserKey    = "touchIDUser"
    static var TouchIDPassKey    = "touchIDPass"
    
    //******** Authenticaiton enum declaration ***********//
    enum LAError : Int {
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case touchIDNotAvailable
        case touchIDNotEnrolled
    }
    
    struct AuthenticationStatus
    {
        var success : Bool = false
        var titleString : String? = ""
        var messageString : String? = ""
    }
    
    struct AuthenticationInfo
    {
        var touchIDUser : String
        var touchIDPass : String
    }
    
    let authenticationContext = LAContext()
    let keychain = Keychain(service: "com.interval.touchToken")
    
    init()
    {
        // DEBUG code used to clear out saved credentials at login for testing
        //clearCurrentKeychainCredentials()
    }
    
    // ***** Returns the username and password for the saved user ***** //
    func getAuthenticationInfo(_ completionHandler:@escaping (_ authInfo:AuthenticationInfo?)->())
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            do {
                let username : String? = try self.keychain.get(TouchID.TouchIDUserKey)
                let password : String?  = try self.keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get(TouchID.TouchIDPassKey)
                
                completionHandler(AuthenticationInfo(touchIDUser: username!, touchIDPass: password!))
            } catch _ {
                // failed to gather authentication info from keychain
                completionHandler(nil)
            }
        }
    }
    
    // ***** Saves the username and password for the user to the keychain ***** //
    func saveAuthenticationInfo(_ username:String, password:String, completionHandler:@escaping (_ success:Bool)->())
    {
        // set the password
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            do {
                // set the username
                try self.keychain.set(username, key: TouchID.TouchIDUserKey)
                
                // set the password. This is touchid managed
                try self.keychain
                    .accessibility(.whenUnlocked, authenticationPolicy: .touchIDCurrentSet)
                    .set(password, key: TouchID.TouchIDPassKey)
                
                // success updated
                completionHandler(true);
            } catch _ {
                // failed to save credentials
                completionHandler(false)
            }
        }
    }
    
    // turn off touchID
    func deactivateTouchID()
    {
        clearCurrentKeychainCredentials()
    }
    
    // ***** function called when user try to use login touch id to validate user *****//
    // ***** Completion handler is called when complete and informs the calls of success *****//
    func authenticateUser(_ completionHandler:@escaping (_ authStatus:AuthenticationStatus)->())
    {
        if authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            authenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: Constant.enableTouchIdMessages.reasonString, reply: { (success:Bool, evalPolicyError:Error?) in
                if success {
                    completionHandler(AuthenticationStatus(success: true, titleString: nil, messageString: nil))
                }
                else{
                    switch (evalPolicyError! as NSError).code {
                        
                    case LAError.authenticationFailed.rawValue:
                        completionHandler(AuthenticationStatus(success: false, titleString: Constant.enableTouchIdMessages.authenticationFailedTitle, messageString: Constant.enableTouchIdMessages.authenticationFailedMessage))
                        
                    case LAError.systemCancel.rawValue:
                        completionHandler(AuthenticationStatus(success: false, titleString: Constant.enableTouchIdMessages.authenticationFailedTitle, messageString: Constant.enableTouchIdMessages.systemCancelMessage))
                        
                    default:
                        completionHandler(AuthenticationStatus(success: false, titleString: Constant.enableTouchIdMessages.authenticationFailedTitle, messageString: Constant.enableTouchIdMessages.systemCancelMessage))
                    }
                }
            })
        }
        else {
            completionHandler(AuthenticationStatus(success: false, titleString: Constant.enableTouchIdMessages.authenticationFailedTitle, messageString: Constant.enableTouchIdMessages.otherMessage))
        }
    }
    
    // ***** Clears the current user's credentials from the keychain ***** //
    fileprivate func clearCurrentKeychainCredentials()
    {
        // clear all keychain items
        do {
            try keychain.remove(TouchID.TouchIDUserKey)
            try keychain.remove(TouchID.TouchIDPassKey)
        } catch let error {
            print("error: \(error)")
        }
    }
    
    // ***** Returns whether there are any saved credentials ***** //
    func haveCredentials() -> Bool
    {
        do {
            if let _ = try keychain.get(TouchID.TouchIDUserKey)
            {
                return true;
            }
        }
        catch {
            
        }
        return false;
    }
    
    // ***** Returns the associated/saved username ***** //
    func getAssociatedUsername() -> String?
    {
        guard let username : String? = try? keychain.getString(TouchID.TouchIDUserKey) else
        {
            return nil
        }
        return username
    }
    
    // Static method - isTouchIDAvailable
    // ***** returns whether touchID is turned on and a fingerprint registered ****** //
    static func isTouchIDAvailable() -> Bool
    {
        let authenticationContext : LAContext = LAContext();
        return authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
