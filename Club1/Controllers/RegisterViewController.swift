//
//  RegisterViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-05.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    var ref : DatabaseReference!
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        errorText.text = ""
    }

    @IBAction func signupButton(_ sender: UIButton) {
        SVProgressHUD.show()
        
        if let email = emailText.text, let password = passwordText.text, let username = usernameText.text {
            Auth.auth().createUser(withEmail: email, password: password) {
                (user, error) in
                
                if error != nil {
                    print("Error Creating A New User: \(error!)")
                    self.errorText.text = "Username/Email/Password Has Been Left Empty"
                }
                else {
                    print("Registration Success")
                    self.ref.child("data/users").updateChildValues(["\(Auth.auth().currentUser!.uid)":["Username":username]])
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            }
        }
        else {
            print("email/password/username has been left empty")
        }
        SVProgressHUD.dismiss()
    }
}
