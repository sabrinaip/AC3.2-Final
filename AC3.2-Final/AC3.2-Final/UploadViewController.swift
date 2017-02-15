//
//  UploadViewController.swift
//  AC3.2-Final
//
//  Created by Sabrina Ip on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase


class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    var databaseReference: FIRDatabaseReference!
    var user: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup Views
    
    func setup() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        photoImageView.image = #imageLiteral(resourceName: "camera_icon")
        photoImageView.contentMode = .center
        
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        self.user = FIRAuth.auth()?.currentUser
    }

    // MARK: - Actions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        print("done button pressed")
        guard let image = self.photoImageView.image,
            image != #imageLiteral(resourceName: "camera_icon"),

            commentTextView.text != nil
            else {
            return
        }
        uploadImage(image: image)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.photoImageView.image = image
            photoImageView.contentMode = .scaleAspectFit
        }
        dismiss(animated: true)
    }

    // MARK: - Upload Image
    
    func uploadImage(image: UIImage) {
        // downsize the image by compressing it
        guard let jpeg = UIImageJPEGRepresentation(image, 0.5) else { return }

        let databaseChild = self.databaseReference.childByAutoId()
        let storageRef = FIRStorage.storage().reference().child("images/\(databaseChild.key)")
        
        let metadata = FIRStorageMetadata()
        metadata.cacheControl = "public,max-age=300";
        metadata.contentType = "image/jpeg";
        
        let _ = storageRef.put(jpeg, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                print("put error")
                return
            }
        }
        
        databaseChild.setValue(["comment" : commentTextView.text!, "userId" : user?.uid], withCompletionBlock: { (error, reference) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Reference is \(reference)")
                self.tabBarController?.selectedIndex = 0
            }
        })
    }
    
}
