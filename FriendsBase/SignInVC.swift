//
//  ViewController.swift
//  FriendsBase
//
//  Created by Vignesh Kumar on 9/8/16.
//  Copyright © 2016 Vignesh Kumar. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper


class SignInVC: UIViewController {

    @IBOutlet weak var emailField: DesignTxtField!
    @IBOutlet weak var passwordField: DesignTxtField!
    
    @IBOutlet weak var pwdWarningLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.defaultKeychainWrapper().stringForKey(KEY_UID){
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }

    }

    @IBAction func facebookBtnTapped(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Unable to authenticate with Facebook - \(error)")
            }else if result?.isCancelled == true {
                print("User cancelled Facebook Authentication")
            }else {
                print("Sucessfully Authenticated with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Unable to authenticate with Firebase - \(error)")
            } else {
                print("Sucessfully Authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        })
    }
    @IBAction func signInTapped(_ sender: AnyObject) {
        
        if let email = emailField.text, let pwd = passwordField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Email User Authenticated with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }

                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            if pwd.characters.count < 6 {
                                self.pwdWarningLbl.isHidden = false
                            }

                            print("Unable to Authenticate with Firebase using email - \(error)")
                        } else {
                            print("Sucessfully authenticated with Firbase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }

                        }
                    })
                }
            })
            
        }
        
    }
    
    func completeSignIn(id: String) {
        let keyChainResult = KeychainWrapper.defaultKeychainWrapper().setString(id, forKey: KEY_UID)
        print("Data saved to keychain \(keyChainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

