//
//  EditProfileViewController.swift
//  WeRide
//
//  Created by Ian Richins on 8/3/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var editUsernameButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var profilePhotoImageView: UIView!
    
    let user = UserController.shared.currentUser
    var image: UIImage? {
        didSet {
            guard let user = user else { return }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        addEmitter()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let user = user else { return }
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        user.username = username
        UserController.shared.update(user: user) { (success) in
            print("user updated")
            DispatchQueue.main.async{
                  self.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfilePhotoButtonTapped(_ sender: Any) {
        func presentPhotoPickerStoryboard() {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "PhotoPicker", bundle: nil)
                guard let viewController = storyboard.instantiateInitialViewController() else { return }
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true)
            }
        }
    }
    
    @IBAction func editUsernameButtonTapped(_ sender: Any) {
        usernameTextField.isUserInteractionEnabled = true
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        guard let user = user else { return }
        UserController.shared.delete(user: user) { (success) in
            if success {
                func presentMainStoryboard() {
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let viewController = storyboard.instantiateInitialViewController() else { return }
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true)
                    }
                }
                
            } else {
                //TODO: handle error
            }
        }
    }
    
    func setUpViews() {
        guard let user = user else { return }
        // profilePhotoImageView.image = user.profilePhoto
        usernameTextField.text = user.username
        usernameTextField.isUserInteractionEnabled = false
        logoImageView.image = #imageLiteral(resourceName: "weRideLogo")
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.height / 2
        profilePhotoImageView.clipsToBounds = true
    }
    
    func addEmitter() {
        let emitter = Emitter.get(with: #imageLiteral(resourceName: "Checkered Flag no background copy"))
        emitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: 0)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        view.layer.insertSublayer(emitter, at: 0)
    }
    
} // END OF CLASS

extension EditProfileViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
}
