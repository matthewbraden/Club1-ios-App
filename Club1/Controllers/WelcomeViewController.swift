//
//  ViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-05.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "goToHome", sender: self)
        }
    }
}

