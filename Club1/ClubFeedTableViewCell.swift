//
//  ClubFeedTableViewCell.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-19.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit

class ClubFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var userSentPhoto: UILabel!
    @IBOutlet weak var imageTaken: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
