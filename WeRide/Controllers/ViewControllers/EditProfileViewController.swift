//
//  EditProfileViewController.swift
//  WeRide
//
//  Created by Ian Richins on 8/3/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var profilePhotoImageView: UIView!
    
    //MARK: - Properties
    let user = UserController.shared.currentUser
    var image: UIImage? //{
//        didSet {
//            guard let user = user else { return }
//            user.profilePhoto = self.image
//            UserController.shared.update(user: user) { (success) in
//                if success {
//                    print("user photo updated")
//                } else {
//                    print("unable to update profile photo")
//                }
//            }
//        }
//    }
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        addEmitter()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let user = user,
      let username = usernameTextField.text, !username.isEmpty else { return }
        let photo = image
        user.username = username
        user.profilePhoto = photo
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
    
    //MARK: - Helpers
    func setUpViews() {
        guard let user = user else { return }
        usernameTextField.text = user.username
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "photoPicker" {
               guard let destinationVC = segue.destination as? PhotoPickerViewController else { return }
               destinationVC.delegate = self
           }
       }
    
} // END OF CLASS

extension EditProfileViewController: PhotoPickerDelegate {
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
}
