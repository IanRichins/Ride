//
//  RideHomeScreenViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/11/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class RideHomeScreenViewController: UIViewController {
    
    //MARK: -Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var yourRidesButton: UIButton!
    @IBOutlet weak var createRideButton: UIButton!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var editProfileButton: UIBarButtonItem!
    
    
    //MARK: -Properties
    var image: UIImage? {
        didSet {
            guard let user = UserController.shared.currentUser else { return }
            UserController.shared.update(user: user) { (success) in
                if success {
                    self.profilePhotoImageView.image = self.image
                    print("user image updated")
                }
            }
        }
    }
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
         setupViews()
    }
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        presentEditProfileStoryboard()
    }
    
    //MARK: -Actions
    @IBAction func yourRidesButtonTapped(_ sender: UIButton) {
        sender.flash()
        presentRideListStoryboard()
    }
    
    @IBAction func createRideButtonTapped(_ sender: UIButton) {
        sender.pulse()
    }
    
    //MARK: -Helpers
    func setupViews() {
        let currentUser = UserController.shared.currentUser
        if currentUser?.profilePhoto == nil {
            profilePhotoImageView.image = .add
        } else {
            profilePhotoImageView.image = currentUser?.profilePhoto
        }
        editProfileButton.title = "Edit Profile"
        usernameLabel.text = currentUser?.username
        createRideButton.layer.cornerRadius = createRideButton.frame.height / 2
        yourRidesButton.layer.cornerRadius = yourRidesButton.frame.height / 2
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.height / 2
        profilePhotoImageView.clipsToBounds = true
        self.view.addBackground()
    }
    
    func presentRideListStoryboard() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "RideList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    func presentEditProfileStoryboard() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "EditProfile", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toPhotoPickerVC" {
               let destinationVC = segue.destination as? PhotoPickerViewController
               destinationVC?.delegate = self
           }
        }   
} // END OF CLASS

extension RideHomeScreenViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
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


