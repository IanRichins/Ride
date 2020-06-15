//
//  SignInViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var profilePhotoContainerView: UIView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        setUpViews()
        addEmitter()
    }
    
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
    
    func presentRideHomeStoryboard() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "RideHomeScreen", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController() else { return }
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    func setUpViews() {
        signInButton.layer.cornerRadius = signInButton.frame.height / 2
        profilePhotoContainerView.layer.cornerRadius = profilePhotoContainerView.frame.height / 2
        profilePhotoContainerView.clipsToBounds = true
        usernameTextField.layer.cornerRadius = usernameTextField.frame.height / 2

    }
    
    func addEmitter() {
        let emitter = Emitter.get(with: #imageLiteral(resourceName: "Flag"))
        emitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: 0)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        view.layer.insertSublayer(emitter, at: 0)
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
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoPickerVC" {
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
     }
     
    
}

extension SignInViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        
        self.image = image
    }
}
