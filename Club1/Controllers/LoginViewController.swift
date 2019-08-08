//
//  LoginViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-05.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorText.text = ""
    }

    @IBAction func loginButton(_ sender: UIButton) {
        SVProgressHUD.show()
        if let email = emailText.text, let password = passwordText.text {
            Auth.auth().signIn(withEmail: email, password: password) {
                (user, error) in
                if error != nil {
                    print("Cannot sign in due to error \(error!)")
                    self.errorText.text = "Incorrect Email/Password"
                    self.passwordText.text = ""
                }
                else {
                    print("Logged in successful")
                    self.performSegue(withIdentifier: "goToHome", sender: self)
                }
            }
        }
        else {
            print("Email/Password field has been left empty")
        }
        SVProgressHUD.dismiss()
    }
}
