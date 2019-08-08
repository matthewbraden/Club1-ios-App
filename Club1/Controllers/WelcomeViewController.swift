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
        
//        let clubDB = Database.database().reference().child("data/clubs")
//
//        let clubDictionary = ["Name" : "Sizzle", "Address" : "25 Hess St S", "Latitude" : 43.2582, "Longitude" : -79.8774, "UserPopulation" : 0] as [String : Any]
//
//        clubDB.childByAutoId().setValue(clubDictionary) {
//            (error, reference) in
//            if error != nil {
//                print(error!)
//            }
//            else {
//                print("Club has been added")
//            }
//        }
    }
}

