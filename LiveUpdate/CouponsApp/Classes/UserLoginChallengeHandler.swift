/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  UserLoginChallengeHandler.swift
//  MyCoupons
//
//  Created by Ishai Borovoy on 14/08/2016.
//

import IBMMobileFirstPlatformFoundation
import AudioToolbox.AudioServices
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



open class UserLoginChallengeHandler : SecurityCheckChallengeHandler {
    open static let securityCheckName = "UserLogin"
    var userLoginViewController : UserLoginViewController?
    
    override init() {
        super.init(name: UserLoginChallengeHandler.securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(self)
    }
    
    override open func handleChallenge(_ challenge: [AnyHashable: Any]!) {
        if (userLoginViewController?.loginPressed >= 1) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        showLoginScreen()
    }
    
    open override func handleSuccess(_ success: [AnyHashable: Any]!) {
        UserDefaults.standard.set(success["user"]!["displayName"]!!, forKey: "displayName")
        UserDefaults.standard.synchronize()
        closeLoginScreen()
        
    }
    
    open override func handleFailure(_ failure: [AnyHashable: Any]!) {
        let alertView = UIAlertView(title: "Login failed", message: "Failed to login, try again later", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
        closeLoginScreen()
    }
    
    fileprivate func closeLoginScreen () {
        if  self.userLoginViewController != nil && self.userLoginViewController!.isPresented {
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: {
                
            })
        }
       
    }
    
    fileprivate func showLoginScreen () {
        if self.userLoginViewController == nil || !self.userLoginViewController!.isPresented {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.userLoginViewController = storyboard.instantiateViewController(withIdentifier: "UserLoginViewController") as? UserLoginViewController
            UIApplication.shared.windows.first?.rootViewController?.present(self.userLoginViewController!, animated: true, completion: {
                
            })
        }
    }

}
