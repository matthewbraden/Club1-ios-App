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
        view.addSubview(mapView)
        
//        let coordinates = [
//            CLLocationCoordinate2D(latitude: 43.258244, longitude: -79.877424),
//            CLLocationCoordinate2D(latitude: 43.258322, longitude: -79.877837),
//            CLLocationCoordinate2D(latitude: 43.258533, longitude: -79.877274)
//        ]
//
//        var pointAnnotations = [MGLPointAnnotation]()
//        for coordinate in coordinates {
//            let point = MGLPointAnnotation()
//            point.coordinate = coordinate
//            point.title = "\(coordinate.latitude), \(coordinate.longitude)"
//            pointAnnotations.append(point)
//        }
//
//        mapView.addAnnotations(pointAnnotations)

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

            mapView.setCenter(mapCenter, zoomLevel: 15, animated: false)
            view.addSubview(mapView)
        }
    }
    
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        let source = MGLVectorTileSource(identifier: "clubs-bars", configurationURL: URL(string: "mapbox://bradenm.1uvubbkp")!)
        
        style.addSource(source)
        
        let layer = MGLCircleStyleLayer(identifier: "clubs", source: source)
        
        layer.sourceLayerIdentifier = "clubs-8nhnyg"
        
        layer.circleColor = NSExpression(forConstantValue: UIColor(red: 1.00, green: 0.72, blue: 0.85, alpha: 1.0))
        
        layer.circleOpacity = NSExpression(forConstantValue: 0.8)
        
        let zoomStops = [
            10: NSExpression(format: "USUERCOUNT + 10"),
            13: NSExpression(format: "USERCOUNT + 10")
        ]

        layer.circleRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", zoomStops)
        
        style.addLayer(layer)
    }
    
    // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
//    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//        // This example is only concerned with point annotations.
//        guard annotation is MGLPointAnnotation else {
//            return nil
//        }
//
//        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
//        let reuseIdentifier = "\(annotation.coordinate.longitude)"
//
//        // For better performance, always try to reuse existing annotations.
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
//
//        // If there’s no reusable annotation view available, initialize a new one.
//        if annotationView == nil {
//            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
//            annotationView!.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
//
//            // Set the annotation view’s background color to a value determined by its longitude.
//            let hue = CGFloat(annotation.coordinate.latitude) / 100
//            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
//        }
//
//        return annotationView
//    }
//
//    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//        return true
//    }
}





//class CustomAnnotationView: MGLAnnotationView {
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        // Use CALayer’s corner radius to turn this view into a circle.
//        layer.cornerRadius = bounds.width / 2
//        layer.borderWidth = 2
//        layer.borderColor = UIColor.white.cgColor
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Animate the border width in/out, creating an iris effect.
//        let animation = CABasicAnimation(keyPath: "borderWidth")
//        animation.duration = 0.1
//        layer.borderWidth = selected ? bounds.width / 4 : 2
//        layer.add(animation, forKey: "borderWidth")
//    }
//}
