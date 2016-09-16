//
//  NewProfileVC.swift
//  FriendsBase
//
//  Created by Vignesh Kumar on 9/15/16.
//  Copyright © 2016 Vignesh Kumar. All rights reserved.
//

import UIKit
import Firebase

class NewProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addImage: CircleView!
    @IBOutlet weak var displayName: DesignTxtField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImage.image = image
            imageSelected = true
        } else {
            print("valid image is not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func submitBtnTapped(_ sender: AnyObject) {
        
        guard let name = displayName.text, name != "" else {
            print("Caption Must be Entered")
            return
        }
        guard let img = addImage.image, imageSelected == true else {
            print("An Image Must be Selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Unable to upload image to Firebase Storage")
                } else {
                    print("Sucessfully uploaded image to firebase storage")
                    let downloadUrl = metadata?.downloadURL()?.absoluteString
                    let user = FIRAuth.auth()?.currentUser
                    if let user = user {
                        let changeRequest = user.profileChangeRequest()
                        print("download url: \(downloadUrl)")
                        changeRequest.displayName = name
                        changeRequest.photoURL =
                            NSURL(string: downloadUrl!) as URL?
                        changeRequest.commitChanges { error in
                            if let error = error {
                                // An error happened.
                                print(error)
                            } else {
                                // Profile updated.
                                print("Profile Updated \(user.photoURL)")
                            }
                        }
                    }
                }
            }
            performSegue(withIdentifier: "goToFeed", sender: nil)
            
        }

        
        
    }
    
    
}
