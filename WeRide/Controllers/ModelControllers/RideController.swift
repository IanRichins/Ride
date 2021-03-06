//
//  RideController.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit
import CloudKit

class RideController {
    //MARK: -Singleton
    static let shared = RideController()
    
    //MARK: -Source Of Truth
    var currentRide: Ride?
    var rides: [Ride] = []
    
    //MARK: -Properties
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: -CRUD functions
    func createRideWith(annotationCoordinates: [CLLocation], rideTitle: String?, annotationTitles: [String] = [""], annotationSubtitles: [String] = [""], completion: @escaping (Result<Ride, UserError>) -> Void) {
        guard let userID = UserController.shared.currentUser?.ckRecordID else { return completion(.failure(.couldNotUnwrap))}
        let reference = CKRecord.Reference(recordID: userID, action: .deleteSelf)
        let newRide = Ride(annotationCoordinates: annotationCoordinates, annotationTitles: annotationTitles, annotationSubtitles: annotationSubtitles, rideTitle: rideTitle, userReference: reference)
        let rideRecord = CKRecord(ride: newRide)
        self.publicDB.save(rideRecord) { (record, error) in
            if let error = error {
                print("Could not create a record")
                print(error.localizedDescription)
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let savedRide = Ride(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap))}
            print("Ride saved: \(record.recordID) sucessfully")
            completion(.success(savedRide))
        }
    }
    
    func fetchRide(completion: @escaping (Result<[Ride], UserError>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RideStrings.typeKey, predicate: predicate)
        self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap))}
            let rides = records.compactMap({Ride(ckRecord: $0)})
            for ride in rides {
                self.currentRide = ride
            }
            
            completion(.success(rides))
        }
    }
    
    func updateRide(_ ride: Ride, completion: @escaping (_ sucess: Bool) -> Void) {
        let recordToUpdate = CKRecord(ride: ride)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print(error.localizedDescription)
                return completion(false)
            }
            
            guard recordToUpdate == records?.first else {
                print("Unexpected error updating the record")
                return completion (false)
            }
            print("updated \(recordToUpdate.recordID) successfully")
        }
        publicDB.add(operation)
    }
    
    func deleteRide(ride: Ride, completion: @escaping (Result<Bool, UserError>) -> Void) {
        let recordToUpdate = CKRecord(ride: ride)
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [recordToUpdate.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(.success(true))
            } else {
                print("Unaccounted records were returned when trying to delete")
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(operation)
    }
    
} // END OF CLASS

