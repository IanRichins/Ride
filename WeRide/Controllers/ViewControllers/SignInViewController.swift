//
//  SignInViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    //MARK: -Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var profilePhotoContainerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    //MARK: -Properties
    var image: UIImage? {
        didSet {
            guard let user = UserController.shared.currentUser else { return }
            user.profilePhoto = self.image
            UserController.shared.update(user: user) { (success) in
                if success {
                    print("user photo updated")
                } else {
                    print("unable to update profile photo")
                }
            }
        }
    }
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        setUpViews()
        addEmitter()
    }
    
    //MARK: -Actions
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        sender.pulse()
        //  guard UserController.shared.currentUser == nil else { self.presentRideHomeStoryboard() ; return }
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        UserController.shared.createUserWith(username, profilePhoto: image) { (result) in
            switch result {
            case .success(let user):
                guard let user = user else {return}
                UserController.shared.currentUser = user
                self.presentRideHomeStoryboard()
            case .failure(let error):
                sender.shake()
                print("There was an error creating a user")
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Helpers
    func setUpViews() {
        signInButton.layer.cornerRadius = signInButton.frame.height / 2
        profilePhotoContainerView.layer.cornerRadius = profilePhotoContainerView.frame.height / 2
        profilePhotoContainerView.clipsToBounds = true
        usernameTextField.layer.cornerRadius = usernameTextField.frame.height / 2
        logoImageView.image = #imageLiteral(resourceName: "weRideLogo")
    }
    
    func fetchUser() {
        UserController.shared.fetchUser { (result) in
            switch result {
            case .success(let user):                
                print("fetched user successfully")
                self.presentRideHomeStoryboard()
                guard let user = user else { return }
                UserController.shared.currentUser = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func presentRideHomeStoryboard() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "RideHomeScreen", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    func addEmitter() {
        let emitter = Emitter.get(with: #imageLiteral(resourceName: "Checkered Flag no background copy"))
        emitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: 0)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        view.layer.insertSublayer(emitter, at: 0)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
    
} // END OF CLASS

extension SignInViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
}

