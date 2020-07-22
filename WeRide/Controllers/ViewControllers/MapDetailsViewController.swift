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
    var annotationCoords: [CLLocationCoordinate2D] = []
    var startLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    var previouseLocation: CLLocation?
    
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var rideTitleLabel: UILabel!
    
    //MARK: -Landinig Pad
    var ride: Ride?
    
    //MARK: -LifeCyles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAnnotationsAndDrawRoute()
        setUpViews()
    }
    
    //MARK: -Actions
    @IBAction func mapViewTapped(_ sender: Any) {
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Helper Methods
    func fetchAnnotationsAndDrawRoute() {
        guard let ride = ride else { return }
        RideController.shared.fetchAnnotationsFor(ride: ride) { (success) in
            switch success {
            case .success(_):
                let annotations = RideController.shared.annotations
                self.detailMapView.addAnnotations(annotations)
                self.detailMapView.reloadInputViews()
                self.drawRoute()
                print("annotations fetched successfully")
            case .failure(let error):
                print("There was an error setting up annotations \(error.localizedDescription)")
            }
        }
    }
    
    func setUpViews() {
        guard let ride = ride else { return }
        rideTitleLabel.text = ride.rideTitle
    }
    
    func drawRoute() {
        let annotations = RideController.shared.annotations
        var coordinates = [CLLocationCoordinate2D]()
        for anno in annotations {
            coordinates.append(anno.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let visibleMapRect = detailMapView.mapRectThatFits(polyline.boundingMapRect, edgePadding : UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        self.detailMapView.setRegion(MKCoordinateRegion(visibleMapRect), animated: true)
        
        var index = 0
        while index < annotations.count - 1 {
            getDirections(startPoint: annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            
            index += 1
        }
    }
    
    func getDirections(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) {
        // Create map items from coordinate
        let startPlacemark = MKPlacemark(coordinate: startPoint, addressDictionary: nil)
        let endPlacemark = MKPlacemark(coordinate: endPoint, addressDictionary: nil)
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        // Set the source and destination of the route
        let directionRequest = MKDirections.Request()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = MKDirectionsTransportType.automobile
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (routeResponse, routeError) -> Void in
            guard let routeResponse = routeResponse else { if let routeError = routeError {
                print("Error: \(routeError)") }
                return
            }
            
            let route = routeResponse.routes[0]
            self.detailMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads) }
    }
    
    //    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
    //        let latitude = mapView.centerCoordinate.latitude
    //        let longitude = mapView.centerCoordinate.longitude
    //
    //        return CLLocation(latitude: latitude, longitude: longitude)
    //    }
    
} // END OF CLASS

extension MapDetailsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let annotationView = views[0]
        let endFrame = annotationView.frame
        annotationView.frame = endFrame.offsetBy(dx: 0, dy: -600)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            annotationView.frame = endFrame
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}
