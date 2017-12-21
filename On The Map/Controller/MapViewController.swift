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

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadLocations()
    }

    func loadLocations() {
        let _ = Client.sharedInstance().taskForGETMethod("\(Constants.Methods.ParseStudentLocation)", completionHandlerGET: { (success, errorString) in
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
    
    @IBAction func logoutTouched(_ sender: Any) {
        Client.sharedInstance().logout({ (success, error) in
            if success {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    @IBAction func refreshTouched(_ sender: Any) {
//        let _ = Client.sharedInstance().putStudentLocation(userId: (appDelegate.user?.userId)!, completionHandlerForPUTStudentLoc: { (value, errorString) in
//            if value != nil {
//                performUIUpdatesOnMain {
//                    print("testMap")
//                    self.mapView.reloadInputViews()
//                }
//            } else {
//                let message = (errorString) ?? "Check your connection, we could not reload the information."
//                let alert = Alerts.errorAlert(title: "Failed to Reload!", message: message)
//                self.present(alert, animated: true, completion: nil)
//            }
//        })
        loadLocations()
    }
 
    @IBAction func addTouched(_ sender: Any) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "LocationNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
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
