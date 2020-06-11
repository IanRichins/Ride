
//  RideAnnotation.swift
//  WeRide
//
//  Created by Ian Richins on 6/5/20.
//  Copyright © 2020 Ian Richins. All rights reserved.


import Foundation
import MapKit
import Contacts

//class RouteAnnotationHelper: NSObject, MKAnnotation {
//    
//    var ride: RouteAnnotation
//    
//    var title: String? {
//        return ride.title
//    }
//    
//    var subtitle: String? {
//        return ride.subtitle
//    }
//    
//    var coordinate: CLLocationCoordinate2D {
//        return CLLocationCoordinate2D(latitude: ride.coordinate.coordinate.latitude, longitude: ride.coordinate.coordinate.longitude)
//    }
//    
//    var placemark: MKPlacemark {
//        return MKPlacemark(coordinate: self.coordinate)
//    }
//    
//    init(ride: RouteAnnotation) {
//        self.ride = ride
//    }
//    
//    func mapItem() -> MKMapItem {
//        let addressDict = [CNPostalAddressStateKey: title!]
//        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = title
//        return mapItem
//    }
//}
