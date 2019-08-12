//
//  SearchViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-09.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var clubTableView: UITableView!
    
    var clubsArray : [Clubs] = [Clubs]()
    
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubTableView.delegate = self
        clubTableView.dataSource = self
        
        clubTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "customClubCell")
        
        // CLLocationManagerDelegate setup
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //        Call the function that retrieves the datava
        clubTableView.rowHeight = 60.0
        retrieveClubs()
        
    }
    
    // MARK: - Table view data soure
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return clubsArray.count
    }

    //    MARK: - Table view cell setup
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customClubCell", for: indexPath) as! SearchTableViewCell
        
        cell.clubTitle.text = "\(clubsArray[indexPath.row].name), (\(clubsArray[indexPath.row].address))"
        
        let clubLat = clubsArray[indexPath.row].latitude
        let clubLong = clubsArray[indexPath.row].longitude
        let userLat = latitude
        let userLong = longitude
        
        let distanceToClub = distance(lat1: clubLat, lon1: clubLong, lat2: userLat, lon2: userLong)
        
        if userLat == 0.0 && userLong == 0.0 {
            tableView.reloadData()
        }
        else {
            let rounded = (distanceToClub * 100).rounded() / 100
            cell.clubDescription.text = "\(clubsArray[indexPath.row].name) is only \(rounded)km away"
        }
        
        return cell
    }
    
    //    MARK: - Setting up the users location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            latitude = Double(location.coordinate.latitude)
            longitude = Double(location.coordinate.longitude)
        }
    }
    
    //    MARK: - Turns degrees to radians
    func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }
    
    //    MARK: - Turns radians to degrees
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }
    
    //    MARK: - Finds the distance between two locations
    func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515 * 1.609344
        return dist
    }
    
    // MARK:- Retrieving the information about clubs from the database and adding an annotation
    func retrieveClubs() {
        var clubDB : DatabaseReference?
        var databaseHandle : DatabaseHandle?
        clubDB = Database.database().reference()
        
        databaseHandle = clubDB?.child("data/clubs").observe(.childAdded) {
            (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            let address = snapshotValue["Address"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            let name = snapshotValue["Name"]!
            let userCount = snapshotValue["UserPopulation"]!
            
            let club = Clubs()
            club.address = address as! String
            club.latitude = latitude as! Double
            club.longitude = longitude as! Double
            club.name = name as! String
            club.userPopulation = userCount as! Int
            
            self.clubsArray.append(club)
            self.clubTableView.reloadData()
        }
    }
}
