//
//  RideListTableViewCell.swift
//  WeRide
//
//  Created by Ian Richins on 6/9/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class RideListTableViewCell: UITableViewCell {

    var ride: Ride? {
        didSet {
            setupViews()
        }
    }
    
    @IBOutlet weak var rideCellImageView: UIImageView!
    @IBOutlet weak var rideTitleLabel: UILabel!
    @IBOutlet weak var rideDateStamp: UILabel!
    
    func setupViews() {
        rideTitleLabel.text = ride?.rideTitle
        rideCellImageView.image = #imageLiteral(resourceName: "CheckeredFlag")
    }

}
