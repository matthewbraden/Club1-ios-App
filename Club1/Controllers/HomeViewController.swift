//
//  HomeViewController.swift
//  Club1
//
//  Created by Matthew Braden on 2019-08-05.
//  Copyright © 2019 Matthew Braden. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Mapbox

class HomeViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var mapView: MGLMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CLLocationManagerDelegate setup
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // MGLMapViewDelegate setup
        mapView.delegate = self
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.74699, longitude: -73.98742), zoomLevel: 9, animated: false)
        mapView.showsUserLocation = true

        // Removing the back state from the navbar
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("Cannot sign the current user out")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()

            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            mapView.setCenter(mapCenter, zoomLevel: 13, animated: false)
        }
    }
}
