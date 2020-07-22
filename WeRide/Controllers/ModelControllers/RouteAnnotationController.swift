//
//  RouteAnnotationController.swift
//  WeRide
//
//  Created by Ian Richins on 6/9/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

//import Foundation
//import CloudKit
//import MapKit
//
//class RouteAnnotationController {
//
//    static let shared = RouteAnnotationController()
//
//    //MARK: -Properties
//    let publicDB = CKContainer.default().publicCloudDatabase
//    var annotations: [RouteAnnotation] = []
//
//    //MARK: -CRUD
//
//    //Create
//    func createAnnotationWith(coordinates: CLLocation,title: String?, subtitle: String?, completion: @escaping (Result<RouteAnnotation, UserError>) -> Void) {
//        guard let currentUser = UserController.shared.currentUser else { return completion(.failure(.couldNotUnwrap))}
//        guard let currentRide = RideController.shared.currentRide else { return completion(.failure(.couldNotUnwrap))}
//        let reference = CKRecord.Reference(recordID: currentUser.ckRecordID, action: .deleteSelf)
//        let newAnno = RouteAnnotation(ride: currentRide, title: title, subtitle: subtitle, coordinate: coordinates, userReference: reference)
//        let annotationRecord = CKRecord(routeAnnotation: newAnno)
//        self.publicDB.save(annotationRecord) { (record, error) in
//            if let error = error {
//                print("There was an error saving this Ride Annotation")
//                print(error.localizedDescription)
//                return completion(.failure(.ckError(error)))
//            }
//
//            guard let record = record,
//                let savedAnnotation = RouteAnnotation(ckRecord: record)
//                else { return completion(.failure(.couldNotUnwrap)) }
//            completion(.success(savedAnnotation))
//            self.annotations.append(savedAnnotation)
//        }
//    }
//    //Fetch
//    func fetchAnnotation(completion: @escaping (Result<Bool, UserError>) -> Void) {
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: RideStrings.typeKey, predicate: predicate)
//        self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return completion(.failure(.ckError(error)))
//            }
//            guard let records = records else { return completion(.failure(.couldNotUnwrap))}
//            let annotations = records.compactMap({RouteAnnotation(ckRecord: $0)})
//            for anno in annotations {
//                self.annotations.append(anno)
//            }
//
//            completion(.success(true))
//        }
//    }
//
//    //Update
//    func updateAnnotation(_ annotation: RouteAnnotation) {
//
//    }
//
//    //Delete
//    func deleteAnnotation(_ annotation: RouteAnnotation) {
//
//    }
//
//}// END OF CLASS
