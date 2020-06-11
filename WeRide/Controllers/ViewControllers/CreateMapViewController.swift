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
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var annoTitleTextField: UITextField!
    @IBOutlet weak var annoSubtitleTextField: UITextField!
    @IBOutlet weak var rideTitleTextField: UITextField!
    @IBOutlet weak var addDetailsButton: UIButton!
    @IBOutlet weak var saveDetailsButton: UIButton!
    
    
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
        setUpViews()
    }
    
    //MARK: -Actions
    @IBAction func startButtonTapped(_ sender: Any) {
        rideTitleTextField.isHidden = true
        startButton.isHidden = true
        addDetailsButton.isHidden = false
       addAnnotationPin()
    
//        let title = "test center location"
//        let subtitle = "for Ride"
//        RideController.shared.createRideWith(coodinates: centerLocaton, title: title, subtitle: subtitle) { (result) in
//            switch result {
//            case .success(_):
//                DispatchQueue.main.async {
//                    self.annoSubtitleTextField.isHidden = false
//                    self.annoTitleTextField.isHidden = false
//                    self.routeCoordinates.append(centerLocaton)
//                    self.fetchRideAndAddAnnotation()
//                    print("Ride Coordinate Saved!!")
//                }
//            case .failure(_):
//                print("error saving the ride coordinates")
//            }
//        }
    }
    
    @IBAction func addDetailsButtonTapped(_ sender: Any) {
        annoTitleTextField.isHidden = false
        annoSubtitleTextField.isHidden = false
        saveDetailsButton.isHidden = false
        
    }
    
    @IBAction func saveDetailsButtonTapped(_ sender: Any) {
       guard let annotationTitle = self.annoTitleTextField.text,
        let annotationSubtitle = self.annoSubtitleTextField.text else { return }
        let annoLat = self.onScreenAnnotations[0].coordinate.latitude
        let annoLon = self.onScreenAnnotations[0].coordinate.longitude
        let coordinate = CLLocation(latitude: annoLat, longitude: annoLon)
        self.onScreenAnnotations[0].title = annotationTitle
        self.onScreenAnnotations[0].subtitle = annotationSubtitle
        self.annotationTitles.append(annotationTitle)
        self.annotationSubtitles.append(annotationSubtitle)
        self.routeCoordinates.append(coordinate)
        self.addDetailsButton.isHidden = true
        self.annoTitleTextField.isHidden = true
        self.annoSubtitleTextField.isHidden = true
        self.addDetailsButton.isHidden = true
        self.saveDetailsButton.isHidden = true
        self.startButton.isHidden = false
        self.rideTitleTextField.isHidden = false
        
        self.mapView.reloadInputViews()
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
        annotation.coordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        mapView.addAnnotation(annotation)
        self.onScreenAnnotations.append(annotation)
//        let routeCoordinate = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//        routeCoordinates.append(routeCoordinate)
    }
    
    //TODO: -Maybe move this
    
//    func createRouteAnnotationFor(rides: [Ride]) {
//        var annotations = self.annotations
//        for ride in rides {
//            let annotation = RouteAnnotation(ride: ride)
//            annotations.append(annotation)
//        }
//        mapView.addAnnotations(annotations)
//    }
//
//    func fetchRideAndAddAnnotation() {
//        RideController.shared.fetchRide { (result) in
//            switch result {
//            case .success(_):
//                DispatchQueue.main.async {
//                    self.createRouteAnnotationFor(rides: RideController.shared.currentRide)
//                    self.reloadInputViews()
//                }
//            case .failure(_):
//                print("Could not find annotations")
//            }
//        }
//    }
    
    func setUpViews() {
        startButton.layer.cornerRadius = startButton.frame.height / 5
        annoTitleTextField.isHidden = true
        annoSubtitleTextField.isHidden = true
        addDetailsButton.isHidden = true
        saveDetailsButton.isHidden = true
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
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
    
}
