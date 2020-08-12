//
//  CreateMapViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/8/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CreateMapViewController: UIViewController {
    
    //MARK: -Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rideTitleTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    
    //MARK: -Properties
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previouseLocation: CLLocation?
    var routeCoordinates: [CLLocation] = []
    var annotationTitles: [String] = [""]
    var annotationSubtitles: [String] = [""]
    var onScreenAnnotations: [MKPointAnnotation] = []
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.isHidden = true
    }
    
    //MARK: -Actions
    @IBAction func LongTapGestureTapped(_ sender: Any) {
        addAnnotationPin()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let title = rideTitleTextField.text
        RideController.shared.createRideWith(annotationCoordinates: routeCoordinates, rideTitle: title, annotationTitles: annotationTitles, annotationSubtitles: annotationSubtitles) { (result) in
            switch result {
            case .success(_):
                print("Successfully saved this ride to the cloud")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(_):
                print("Unable to save this ride to the cloud")
            }
        }
    }
    
    //MARK: -Helper Methods
    func addAnnotationPin() {
        let annotation = MKPointAnnotation()
        // Get CLLocation to save to CloudKit
        let annotationCoordinates = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        self.routeCoordinates.append(annotationCoordinates)
        // Get CLLocationCoordinate2D for adding annotations
        annotation.coordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        self.onScreenAnnotations.append(annotation)
        mapView.showAnnotations(onScreenAnnotations, animated: true)
        drawRoute()
    }
    
    func drawRoute() {
        // mapView.removeOverlays(mapView.overlays)
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in onScreenAnnotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let visibleMapRect = mapView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        self.mapView.setRegion(MKCoordinateRegion(visibleMapRect), animated: true)
    
            var index = 0
            while index < onScreenAnnotations.count - 1 {
                drawDirection(startPoint: onScreenAnnotations[index].coordinate, endPoint: onScreenAnnotations[index + 1].coordinate)
                index += 1
        }
    }
    
    func drawDirection(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) {
        
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
                print("Error: \(routeError)")
                
                }
                return
            }
            
            let route = routeResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //TODO: -Show an alert
            break
        case .denied:
            //TODO: -Show alert instructing them how to turn on permissions
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        @unknown default:
            fatalError()
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previouseLocation = getCenterLocation(for: mapView)
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
} // END OF CLASS

//MARK: -Extensions
extension CreateMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
            if let oldLocationNew = oldLocation as CLLocation?{
                let oldCoordinates = oldLocationNew.coordinate
                let newCoordinates = newLocation.coordinate
                var area = [oldCoordinates, newCoordinates]
                let polyline = MKPolyline(coordinates: &area, count: area.count)
                mapView.addOverlay(polyline)
            }
            print("present location : \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        }
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension CreateMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previouseLocation = self.previouseLocation else { return }
        
        guard center.distance(from: previouseLocation) > 50 else { return }
        self.previouseLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print ("Error in \(#function) : \(error.localizedDescription) \n----\n \(error)")
            }
            guard let placemark = placemarks?.first else {
                // TODO: Create an alert to inform the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
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
