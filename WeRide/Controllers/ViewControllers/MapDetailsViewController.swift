//
//  MapDetailsViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/10/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit
import MapKit

class MapDetailsViewController: UIViewController {

    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var rideTitleLabel: UILabel!
    
    //MARK: -Landinig Pad
    var ride: Ride?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAnnotatoinsAndAddToMap()
    }
    
    func setUpViews() {
        rideTitleLabel.text = ride?.rideTitle
    }

    func fetchAnnotatoinsAndAddToMap() {
        let annotation = MKPointAnnotation()
        var annotatonCords = CLLocationCoordinate2D()
        
        guard let ride = ride else { return }
        for coords in ride.annotationCoordinates {
            let annoLat = coords.coordinate.latitude
            let annoLon = coords.coordinate.longitude
            annotatonCords = CLLocationCoordinate2D(latitude: annoLat, longitude: annoLon)
        }
        
        annotation.coordinate = annotatonCords
        detailMapView.addAnnotation(annotation)
    }
    
    
}
