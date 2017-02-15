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


class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    var commentTextViewBottomConstraint: NSLayoutConstraint?
    
    var databaseReference: FIRDatabaseReference!
    var user: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup Views
    
    func setup() {
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        self.user = FIRAuth.auth()?.currentUser
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        photoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        photoImageView.image = #imageLiteral(resourceName: "camera_icon")
        photoImageView.contentMode = .center
        photoImageView.backgroundColor = UIColor.groupTableViewBackground
        
        commentTextView.text = "Add a description..."
        commentTextView.textColor = UIColor.groupTableViewBackground
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        
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
    
    // MARK: - TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add a description..." {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        

        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.isEmpty {
            textView.text = "Add a description..."
            textView.textColor = UIColor.groupTableViewBackground
        }
        return true
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add a description..."
            textView.textColor = UIColor.groupTableViewBackground
        }
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
            guard error == nil else {
                let errorAlertController = UIAlertController(title: "Upload Failed!", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
                return
            }
            
            let successAlertController = UIAlertController(title: "Photo Uploaded", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            successAlertController.addAction(okay)
            self.present(successAlertController, animated: true, completion: nil)
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
    
    // MARK: - Keyboard functions
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewBottomConstraint.isActive = false
            scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardSize.height)
            scrollViewBottomConstraint.isActive = true
            
//            commentTextViewBottomConstraint?.isActive = false
//            commentTextViewBottomConstraint = commentTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardSize.height)
//            commentTextViewBottomConstraint?.isActive = true
//            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollViewBottomConstraint.isActive = false
        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
        scrollViewBottomConstraint.isActive = true
    
//        commentTextViewBottomConstraint?.isActive = false
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
