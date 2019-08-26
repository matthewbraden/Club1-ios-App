//
//  ClubFeedTableViewCell.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-19.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit


protocol ClubFeedTableView {
    func onClickCell(index : Int)
}

class ClubFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var userSentPhoto: UILabel!
    @IBOutlet weak var imageTaken: UIImageView!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var likeClick: UIButton!
    @IBOutlet weak var dislikeClick: UIButton!
    
    var cellDelegate : ClubFeedTableView?
    var index : IndexPath?
    
    var count : Int = 0
    
    var userClickedLike : Bool = false
    var userClickedDislike : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        cellDelegate?.onClickCell(index: index!.row)
        if !userClickedLike && userClickedDislike{
            count += 2
            totalScore.text = String(count)
            userClickedLike = true
            sender.setTitleColor(UIColor.blue, for: UIControl.State.normal)
            dislikeClick.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
        else if !userClickedLike && !userClickedDislike {
            count += 1
            totalScore.text = String(count)
            userClickedLike = true
            sender.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        }
        else if userClickedLike {
            count -= 1
            totalScore.text = String(count)
            userClickedLike = false
            sender.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
        userClickedDislike = false
    }
    
    @IBAction func dislikeButton(_ sender: UIButton) {
        cellDelegate?.onClickCell(index: index!.row)
        if !userClickedDislike && userClickedLike {
            count -= 2
            totalScore.text = String(count)
            userClickedDislike = true
            sender.setTitleColor(UIColor.blue, for: UIControl.State.normal)
            likeClick.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
        else if !userClickedDislike && !userClickedLike {
            count -= 1
            totalScore.text = String(count)
            userClickedDislike = true
            sender.setTitleColor(UIColor.blue, for: UIControl.State.normal)

        }
        else if userClickedDislike {
            count += 1
            totalScore.text = String(count)
            userClickedDislike = false
            sender.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
        userClickedLike = false
    }
}
