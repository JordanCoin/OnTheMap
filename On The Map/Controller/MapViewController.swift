//
//  MapViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/14/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadLocations()
    }

    func loadLocations() {
        let _ = Client.sharedInstance().taskForGETMethod(Client.sharedInstance().sessionID, "\(Client.Constants.Parse.baseURL)\(Client.Constants.Parse.StudentLocation)", handler: { (success, errorString) in
            if success {

                performUIUpdatesOnMain {
                    self.mapView.addAnnotations(self.pinLocations())
                }
                
            } else {
                let alert = Alerts.errorAlert(title: "Check your network!", message: errorString)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: Pin Students on Map
    
    func pinLocations() -> [MKAnnotation] {
        
        // Point annotations (pin) stored in an array
        var annotations = [MKPointAnnotation]()
        
        // Go through our StudentLocation array and create the pins
        for dictionary in StudentLocationCollection.totalLocations {

            let lat = CLLocationDegrees(dictionary.latitude!)
            let long = CLLocationDegrees(dictionary.longitude!)

            let coordinate = CLLocationCoordinate2DMake(lat, long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        return annotations
    }
    
    // MKMapViewDelegate Method
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
