//
//  UserController.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit
import CloudKit

class UserController {
    
    //MARK: -Singleton
    static let shared = UserController()
    
    //MARK: -Source Of Truth
    var currentUser: User?
    
    //MARK: -Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: -CRUD functions
    func createUserWith(_ username: String, profilePhoto: UIImage?, completion: @escaping (Result<User?, UserError>) -> Void) {
        fetchAppleUserReference { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn)) }
                let newUser = User(userName: username, userReference: reference, profilePhoto: profilePhoto)
                let record = CKRecord(user: newUser)
                self.publicDB.save(record) { (record, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = record,
                        let savedUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap)) }
                    self.currentUser = savedUser
                    print("Created User: \(record.recordID.recordName) successfully")
                    completion(.success(savedUser))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchUser(completion: @escaping (Result<User?, UserError>) -> Void) {
        fetchAppleUserReference { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn)) }
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.userReferenceKey, reference])
                let query = CKQuery(recordType: UserStrings.typeKey, predicate: predicate)
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    
                    guard let record = records?.first,
                        let foundUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap)) }
                    self.currentUser = foundUser
                    print("Fetched User: \(record.recordID.recordName) successfully")
                    completion(.success(foundUser))
                }
            case.failure(let error):
                print("Unable to fetch a user")
                print(error.localizedDescription)
            }
        }
    }
    
    //    func fetchUserFor(_ ride: Ride, completion: @escaping (Result<User, UserError>) -> Void) {
    //        guard let userID = ride.userReference?.recordID else { return completion(.failure(.unexpectedRecordsFound)) }
    //
    //        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["recordID", userID])
    //        let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
    //        publicDB.perform(query, inZoneWith: nil) { (records, error) in
    //            if let error = error {
    //                completion(.failure(.ckError(error)))
    //            }
    //
    //            guard let record = records?.first,
    //                let foundUser = User(ckRecord: record)
    //                else { return completion(.failure(.couldNotUnwrap)) }
    //            print("Found user for hype")
    //            completion(.success(foundUser))
    //        }
    //    }
    
    private func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, UserError>) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(.success(reference))
            }
        }
    }
    
    func update(user: User, completion: @escaping (_ success: Bool) -> Void) {
        let recordToUpdate = CKRecord(user: user)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard recordToUpdate == records?.first else {
                print("error: unexpected record")
                completion(false)
                return
            }
            print("updated record succesfully")
            completion(true)
        }
        publicDB.add(operation)
    }
    
    func delete(user: User, completion: @escaping (_ success: Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [user.ckRecordID])
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            if user.ckRecordID == recordIDs?.first {
                print("successfully removed User")
                completion(true)
                return
            }
        }
        publicDB.add(operation)
    }
}
