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
    @IBOutlet weak var yourRidesButton: UIButton!
    @IBOutlet weak var createRideButton: UIButton!
    @IBOutlet weak var photoPickerContainerView: UIView!
    
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @IBAction func yourRidesButtonTapped(_ sender: UIButton) {
        sender.flash()
    }
    
    @IBAction func createRideButtonTapped(_ sender: UIButton) {
        sender.pulse()
    }
    
    func setupViews() {
        let currentUser = UserController.shared.currentUser
        usernameLabel.text = currentUser?.username
        createRideButton.layer.cornerRadius = createRideButton.frame.height / 2
        yourRidesButton.layer.cornerRadius = yourRidesButton.frame.height / 2
        photoPickerContainerView.layer.cornerRadius = photoPickerContainerView.frame.height / 2
        self.view.addBackground()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toPhotoPickerVC" {
               let destinationVC = segue.destination as? PhotoPickerViewController
               destinationVC?.delegate = self
           }
        }   
}

extension UIView {
    func addBackground() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageBackground = UIImageView(frame: CGRect(x: 0,y: 0, width: width, height: height))
        imageBackground.image = UIImage(imageLiteralResourceName: "Background")
        
        imageBackground.contentMode = UIView.ContentMode.scaleToFill
        self.addSubview(imageBackground)
        self.sendSubviewToBack(imageBackground)
        
    }
}
extension RideHomeScreenViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        
        self.image = image
    }
}
