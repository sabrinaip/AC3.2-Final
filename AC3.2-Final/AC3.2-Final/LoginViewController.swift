//
//  LoginViewController.swift
//  AC3.2-Final
//
//  Created by Sabrina Ip on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }

    

    // MARK: - Actions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        print("-------LOGIN TAPPED-----")

        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                let errorAlertController = UIAlertController(title: "Incomplete Information", message: "Please enter your password and email", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
                return }
        self.loginButton.isEnabled = false
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            self.loginButton.isEnabled = true
            guard error == nil else {
                let errorAlertController = UIAlertController(title: "Login Failed!", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
                return
            }

            // TO DO: Get both alertcontroller and loginVC to dismiss
            
/*
            let successAlertController = UIAlertController(title: "Login Sucessful", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            successAlertController.addAction(okay)
            self.present(successAlertController, animated: true, completion: nil)
*/
            
            //clear password text field but keep username
            self.passwordTextField.text = nil
            self.dismiss(animated: true, completion: nil)
        })

    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        print("-------Register TAPPED-----")
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                let errorAlertController = UIAlertController(title: "Incomplete Information", message: "Please enter your password and email", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
                return }
        self.registerButton.isEnabled = false
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            self.registerButton.isEnabled = true
            guard error == nil else {
                let errorAlertController = UIAlertController(title: "Registration Error!", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                errorAlertController.addAction(okay)
                self.present(errorAlertController, animated: true, completion: nil)
                return
            }
            
            // TO DO: Get both alertcontroller and loginVC to dismiss
/*
            let successAlertController = UIAlertController(title: "Registration Sucessful", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            successAlertController.addAction(okay)
            self.present(successAlertController, animated: true, completion: nil)
*/
            
            //clear password text field but keep username
            self.passwordTextField.text = nil
            
            self.dismiss(animated: true, completion: nil)
            



            /*
            //creating users for db
            let uid = newUser.uid
            let databaseReference = FIRDatabase.database().reference().child("USERS/\(uid)")
            let info: [String: AnyObject] = [
                "name" : "\(firstName) \(lastName)" as AnyObject,
                "email" : userName as AnyObject
            ]
            databaseReference.setValue(info)
            
            // UPLOAD PROFILE PICTURE
            if let image = self.profilePictureImageView.image,
                image != #imageLiteral(resourceName: "default-placeholder"),
                let imageData = UIImageJPEGRepresentation(image, 0.8) {
                
                let storageReference = FIRStorage.storage().reference().child("ProfilePictures").child("\(uid)")
                let uploadMetadata = FIRStorageMetadata()
                uploadMetadata.contentType = "image/jpeg"
                
                //upload image data to Storage reference
                let uploadTask = storageReference.put(imageData, metadata: uploadMetadata) { (metadata: FIRStorageMetadata?, error: Error?) in
                    if let error = error {
                        print("Encountered an error: \(error.localizedDescription)")
                    }
                }
            }
            self.signInUser = validUser
            let userHomeVC = UserHomeViewController()
            userHomeVC.photoImageView.image = self.profilePictureImageView.image
            self.navigationController?.pushViewController(userHomeVC, animated: true)
            */
        })

        
    }
    
}
