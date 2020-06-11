//
//  RouteAnnotation.swift
//  WeRide
//
//  Created by Ian Richins on 6/9/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

//import Foundation
//import MapKit
//import CloudKit
//
//struct RouteAnnotationStrings {
//    static let typeKey = "RideAnnotations"
//    static let titleKey = "title"
//    static let subtitleKey = "subtitle"
//    static let coordinateKey = "coordinate"
//    static let userReferenceKey = "userReference"
//}
//
//class RouteAnnotation {
//    var ride: Ride?
//    var title: String?
//    var subtitle: String?
//    var coordinate: CLLocation
//    let ckRecordID: CKRecord.ID
//    let userReference: CKRecord.Reference
//    
//    init(ride: Ride?,title: String?, subtitle: String?, coordinate: CLLocation, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference) {
//        self.ride = ride
//        self.title = title
//        self.subtitle = subtitle
//        self.coordinate = coordinate
//        self.ckRecordID = ckRecordID
//        self.userReference = userReference
//
//    }
//}
//
//extension RouteAnnotation {
//    convenience init?(ckRecord: CKRecord) {
//        guard let title = ckRecord[RouteAnnotationStrings.titleKey] as? String?,
//            let subtile = ckRecord[RouteAnnotationStrings.subtitleKey] as? String?,
//            let coordinate = ckRecord[RouteAnnotationStrings.coordinateKey] as? CLLocation,
//            let userReference = ckRecord[RouteAnnotationStrings.userReferenceKey] as? CKRecord.Reference
//            else { return nil }
//
//        self.init(title: title, subtitle: subtile, coordinate: coordinate, ckRecordID: ckRecord.recordID, userReference: userReference)
//    }
//}
//
//extension CKRecord {
//    convenience init(routeAnnotation: RouteAnnotation) {
//        self.init(recordType: RouteAnnotationStrings.typeKey, recordID: routeAnnotation.ckRecordID)
//        self.setValuesForKeys([
//            RouteAnnotationStrings.titleKey : routeAnnotation.title,
//            RouteAnnotationStrings.subtitleKey : routeAnnotation.subtitle,
//            RouteAnnotationStrings.coordinateKey : routeAnnotation.coordinate,
//            RouteAnnotationStrings.userReferenceKey : routeAnnotation.userReference,
//        ])
//    }
//}

