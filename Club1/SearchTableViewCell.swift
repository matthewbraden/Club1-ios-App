//
//  SearchTableViewCell.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-12.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet var clubBackground: UIView!
    @IBOutlet var clubTitle: UILabel!
    @IBOutlet var clubDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
