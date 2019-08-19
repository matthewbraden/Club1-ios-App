//
//  ClubViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-14.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase
import UberRides
import CoreLocation

class ClubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var clubFeedTableView: UITableView!
    
    var club : Clubs = Clubs()
    var clubID : [DataSnapshot] = [DataSnapshot]()

    var photo : [String] = ["Sup", "Clubs", "Ding dong"]

    var textPassedOverName : String?
    var latPassedOver : Double?
    var longPassedOver : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clubFeedTableView.delegate = self
        clubFeedTableView.dataSource = self
       
        clubFeedTableView.register(UINib(nibName: "ClubFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "customFeedCell")
        
        clubFeedTableView.rowHeight = 350
        
        navigationItem.title = textPassedOverName!
        retrieveClub()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFeedCell", for: indexPath) as! ClubFeedTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photo.count
    }
    
    //    MARK : - Retrieve clubs from database function
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
                    let userCount = rest["UserPopulation"]!
                    
                    self.club.address = address as! String
                    self.club.latitude = latitude as! Double
                    self.club.longitude = longitude as! Double
                    self.club.name = self.textPassedOverName!
                    self.club.userPopulation = userCount as! Int
                    self.club.distance = 0.0
                    
//                    self.clubAddress.text = self.club.address
//                    self.userCount.text = String(self.club.userPopulation)
                    
                    // MARK : - Configure the uber api call
                    let button = RideRequestButton()
                    let ridesClient = RidesClient()

                    let pickupLocation = CLLocation(latitude: self.latPassedOver!, longitude: self.longPassedOver!)
                    let dropoffLocation = CLLocation(latitude: self.club.latitude, longitude: self.club.longitude)

                    let builder = RideParametersBuilder()
                    builder.pickupLocation = pickupLocation
                    builder.dropoffLocation = dropoffLocation
                    builder.dropoffAddress = self.club.address
                    builder.dropoffNickname = self.club.name

                    button.rideParameters = builder.build()
                    button.loadRideInformation()

//                    button.center = self.view.center
//                    self.view.addSubview(button)
                }
            }
        })
    }
}
