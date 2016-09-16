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
    @IBOutlet weak var emailWarningLbl: UILabel!
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
        
        facebookLogin.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
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
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
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
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)                    }

                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            if pwd.characters.count < 6 {
                                self.pwdWarningLbl.isHidden = false
                            }
                            if error.debugDescription.contains("email") == true || email.characters.count < 1 {
                    
                                if error.debugDescription.contains("already in use") == true {
                                    self.emailWarningLbl.text = "* Email Already in Use"
                                }
                                self.emailWarningLbl.isHidden = false
                            }

                            print("Unable to Authenticate with Firebase using email - \(error)")
                        } else {
                            print("Sucessfully authenticated with Firbase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }

                        }
                    })
                }
            })
            
        }
        
    }
    
    
    func completeSignIn(id: String, userData: Dictionary<String,String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keyChainResult = KeychainWrapper.defaultKeychainWrapper().setString(id, forKey: KEY_UID)
        print("Data saved to keychain \(keyChainResult)")
        if let provider = userData["provider"] {
            if provider == "facebook.com" {
                performSegue(withIdentifier: "goToFeed", sender: nil)
            } else {
                performSegue(withIdentifier: "goToNewProfile", sender: nil)
            }
        }
    }

}

