//
//  User.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit
import CloudKit

struct UserStrings {
    static let typeKey = "User"
    static let usernameKey = "Username"
    static let userReferenceKey = "userReference"
    static let photoAssetKey = "PhotoAsset"
}

class User {
    var username: String
    let ckRecordID: CKRecord.ID
    let userReference: CKRecord.Reference
    var profilePhoto: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var photoData: Data?
    
    var photoAsset: CKAsset? {
        guard photoData != nil else { return nil }
        let tempDirectory = NSTemporaryDirectory()
        let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
        let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        do {
            try photoData?.write(to: fileURL)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        return CKAsset(fileURL: fileURL)
    }
    
    init(userName: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference, profilePhoto: UIImage? = nil) {
        self.username = userName
        self.ckRecordID = ckRecordID
        self.userReference = userReference
        self.profilePhoto = profilePhoto
    }
}

extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
            let userReference = ckRecord[UserStrings.userReferenceKey] as? CKRecord.Reference else { return nil }
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not find image data")
            }
        }
        
        self.init(userName: username, ckRecordID: ckRecord.recordID, userReference: userReference, profilePhoto: foundPhoto)
    }
}

extension CKRecord {
    
    convenience init(user: User) {
        self.init(recordType: UserStrings.typeKey, recordID: user.ckRecordID)
        self.setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.userReferenceKey : user.userReference
        ])
        if let asset = user.photoAsset {
            self.setValue(asset, forKey: UserStrings.photoAssetKey)
        }
    }
}

