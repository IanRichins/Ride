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
    
   // var newAnnotations: [RouteAnnotation] = []
   // var annotations: [RouteAnnotationHelper] = []
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

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

    func drawPolyline() {
        var annotationCoordinates: [CLLocationCoordinate2D] = []
        if onScreenAnnotations.count >= 1 {
            for anno in onScreenAnnotations {
               let coord = anno.coordinate
                annotationCoordinates.append(coord)
                
                let polyline = MKPolyline(coordinates: annotationCoordinates, count: annotationCoordinates.count)
                
                mapView.addOverlay(polyline)
                mapView.reloadInputViews()
            }
        }
    }
    
    func addAnnotationPin() {
        let annotation = MKPointAnnotation()
        let annotationCoordinates = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        annotation.coordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        mapView.addAnnotation(annotation)
        self.routeCoordinates.append(annotationCoordinates)
        self.onScreenAnnotations.append(annotation)
        drawPolyline()
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //Show an alert
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
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
    
    func getDirections() {
        let location = self.routeCoordinates[0].coordinate
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
                self.mapView.addOverlay(route.polyline)
                // resizes the map to show the entire route
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = self.routeCoordinates[1].coordinate
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

//MARK: -Extensions
extension CreateMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
           let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
           renderer.strokeColor = .green
           return renderer
       }
}
