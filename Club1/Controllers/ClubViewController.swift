//
//  ClubViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-14.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase

class ClubViewController: UIViewController {
    
    @IBOutlet weak var clubName: UILabel!
    @IBOutlet weak var clubAddress: UILabel!
    @IBOutlet weak var userCount: UILabel!
    @IBOutlet weak var clubImage: UIImageView!
    
    
    var club : Clubs = Clubs()
    var clubID : [DataSnapshot] = [DataSnapshot]()

    var textPassedOverName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = textPassedOverName!
        retrieveClub()
    }
 

    func retrieveClub() {
        
        var clubDB : DatabaseReference?
        var databaseHandle : DatabaseHandle?
        clubDB = Database.database().reference()
        
        clubDB?.child("data/clubs").observe(.value, with: {
            (snapshot) in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let rest = rest.value as! Dictionary<String, Any>
                let name = rest["Name"]!
                let objectName = self.textPassedOverName!
                if objectName as! String == name as! String {
                    let address = rest["Address"]!
                    let latitude = rest["Latitude"]!
                    let longitude = rest["Longitude"]!
                    let name = rest["Name"]!
                    let userCount = rest["UserPopulation"]!
                    
                    self.club.address = address as! String
                    self.club.latitude = latitude as! Double
                    self.club.longitude = longitude as! Double
                    self.club.name = name as! String
                    self.club.userPopulation = userCount as! Int
                    self.club.distance = 0.0
                    
                    self.clubName.text = self.club.name
                    self.clubAddress.text = self.club.address
                    self.userCount.text = String(self.club.userPopulation)
                }
            }
        })
    }
}
