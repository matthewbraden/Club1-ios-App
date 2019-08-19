//
//  FavouritesViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-17.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var favouriteTableView: UITableView!
    
    var favouriteArray : [Clubs] = [Clubs]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favouriteTableView.delegate = self

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath)
        
        return cell
    }
}
