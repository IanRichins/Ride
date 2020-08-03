//
//  PhotoPickerViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/10/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

protocol PhotoPickerDelegate: class {
    func photoPickerSelected(image: UIImage)
}

class PhotoPickerViewController: UIViewController {
    
    //MARK: -Singleton
    static let shared = PhotoPickerViewController()
    
    //MARK: -Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    //MARK: -Properties
    let user = UserController.shared.currentUser
     let imagePicker = UIImagePickerController()
    //MARK: -Set Delegate
    weak var delegate: PhotoPickerDelegate?
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    //MARK: -Actions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add a photo", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openGallery()
        }
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: -Helper
    func setupViews() {
           photoImageView.contentMode = .scaleAspectFill
           photoImageView.clipsToBounds = true
            photoImageView.image = .add
        photoImageView.backgroundColor = .lightGray
           imagePicker.delegate = self
       }
    
} // END OF CLASS

extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Camera Access", message: "Please allow access to the camera to use this feature.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Photos Access", message: "Please allow access to Photos to use this feature.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            guard let delegate = delegate
                else { return }
            delegate.photoPickerSelected(image: pickedImage)
            photoImageView.image = pickedImage

        }
        picker.dismiss(animated: true, completion: nil)
    }
}
