//
//  RideHomeScreenViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/11/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class RideHomeScreenViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var yourRidesButton: UIButton!
    @IBOutlet weak var createRideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        let currentUser = UserController.shared.currentUser
        usernameLabel.text = currentUser?.username
        userProfileImageView.image = currentUser?.profilePhoto
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
