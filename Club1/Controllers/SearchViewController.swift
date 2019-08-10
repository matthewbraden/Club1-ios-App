//
//  SearchViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-09.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var clubTableView: UITableView!
    
    var clubsArray : [Clubs] = [Clubs]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clubTableView.delegate = self
        clubTableView.dataSource = self
        
        clubTableView.register(UINib(nibName: "ClubCell", bundle: nil), forCellReuseIdentifier: "customClubCell")
        
        //        Call the function that retrieves the datava
        configureTableView()
        retrieveClubs()
        
    }
    
    // MARK: - Table view data soure
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return clubsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customClubCell", for: indexPath) as! CustomClubCell

        cell.title.text = clubsArray[indexPath.row].name
        cell.clubDesciption.text = "\(clubsArray[indexPath.row].address), 5.0km away"

        return cell
    }
    
    func retrieveClubs() {
        var clubDB : DatabaseReference?
        var databaseHandle : DatabaseHandle?
        clubDB = Database.database().reference()
        
        
        // MARK:- Retrieving the information about clubs from the database and adding an annotation
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
            self.configureTableView()
            self.clubTableView.reloadData()
        }
    }
    
    func configureTableView() {
        clubTableView.rowHeight = UITableView.automaticDimension
        clubTableView.estimatedRowHeight = 120.0
    }
    
}
