//
//  MapDetailsViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/10/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapDetailsViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var annotations = [MKPointAnnotation]()
    var annotationCoords: [CLLocationCoordinate2D] = []
    var startLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var rideTitleLabel: UILabel!
    
    //MARK: -Landinig Pad
    var ride: Ride?
    
    var annotationCoordinates = [CLLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
         detailMapView.reloadInputViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAnnotatoinsAndAddToMap()
        drawDirections()
    }
    
    @IBAction func mapViewTapped(_ sender: Any) {
        
    }
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setUpViews() {
        guard let ride = ride else { return }
        rideTitleLabel.text = ride.rideTitle
        let coordinatesArray = ride.annotationCoordinates
        for coordinates in coordinatesArray {
            let annotationCoordinate = coordinates.coordinate
            annotationCoords.append(annotationCoordinate)
        }
    }
    
    func fetchAnnotatoinsAndAddToMap() {
        
        var annotationCords = CLLocationCoordinate2D()
        
        guard let ride = ride else { return }
        for coords in ride.annotationCoordinates {
            let annotation = MKPointAnnotation()
            let annoLat = coords.coordinate.latitude
            let annoLon = coords.coordinate.longitude
            annotationCords = CLLocationCoordinate2D(latitude: annoLat, longitude: annoLon)
            annotation.coordinate = annotationCords
            
            annotations.append(annotation)
        }
        
        detailMapView.addAnnotations(annotations)
    }
    
    func drawDirections() {
        if annotations.count >= 1 {
            for annotation in annotations {
                startLocation = annotation.coordinate
                self.getDirections()
                detailMapView.reloadInputViews()
                destinationLocation = annotation.coordinate
                
            }
        }
    }
    
    func getDirections() {
        
        guard let location = startLocation else { return }
        //TODO: Alert user we dont have their current location
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        
        directions.calculate { [unowned self] (response, error) in
            if let error = error {
                print ("Error in \(#function) : \(error.localizedDescription) \n----\n \(error)")
            }
            guard let response = response else { return } //TODO: Show response not available in alert
            
            
            for route in response.routes {
                // these are the instructions
                //    let steps = route.steps
                // ADDS THE BLUE LINES.
                self.detailMapView.addOverlay(route.polyline)
                // resizes the map to show the entire route
                // self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        guard let destinationCoordinate = destinationLocation else { return MKDirections.Request() }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        // request.requestsAlternateRoutes = true
        
        return request
    }
    
} // END OF CLASS

extension MapDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}
