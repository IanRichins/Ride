//
//  Ride.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//
import UIKit.UIImage
import MapKit
import CloudKit

struct RideStrings {
    
    static let typeKey = "Ride"
    static let annotationsKey = "annotationCoordinates"
    static let rideTitleKey = "rideTitle"
    static let annotationTitleKey = "annotationTitles"
    static let annotationSubtitleKey = "annotationSubtitles"
    static let userReferenceKey = "userReference"
}

class Ride {
    var annotationCoordinates: [CLLocation]
    var rideTitle: String?
    var annotationTitles: [String]
    var annotationSubtitles: [String]
    let userReference: CKRecord.Reference
    let ckRecordID: CKRecord.ID
    
    init(annotationCoordinates: [CLLocation], annotationTitles: [String] = [""], annotationSubtitles: [String] = [""], rideTitle: String?, userReference: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.annotationCoordinates = annotationCoordinates
        self.rideTitle = rideTitle
        self.annotationTitles = annotationTitles
        self.annotationSubtitles = annotationSubtitles
        self.userReference = userReference
        self.ckRecordID = ckRecordID
    }
}

extension Ride: Equatable {
    static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.ckRecordID == rhs.ckRecordID
    }
}

extension Ride {
    convenience init?(ckRecord: CKRecord) {
        guard let annotationCoordinates = ckRecord[RideStrings.annotationsKey] as? [CLLocation],
            let rideTitle = ckRecord[RideStrings.rideTitleKey] as? String?,
            let annotationTitles = ckRecord[RideStrings.annotationTitleKey] as? [String],
            let annotationSubtitles = ckRecord[RideStrings.annotationSubtitleKey] as? [String],
            let userReference = ckRecord[RideStrings.userReferenceKey] as? CKRecord.Reference else { return nil }

        self.init(annotationCoordinates: annotationCoordinates, annotationTitles: annotationTitles, annotationSubtitles: annotationSubtitles, rideTitle: rideTitle, userReference: userReference, ckRecordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(ride: Ride) {
        self.init(recordType: RideStrings.typeKey, recordID: ride.ckRecordID)
        self.setValuesForKeys([
            RideStrings.userReferenceKey : ride.userReference,
            RideStrings.annotationsKey : ride.annotationCoordinates,
            RideStrings.rideTitleKey : ride.rideTitle,
            RideStrings.annotationTitleKey : ride.annotationTitles,
            RideStrings.annotationSubtitleKey : ride.annotationSubtitles
        ])
    }
}
