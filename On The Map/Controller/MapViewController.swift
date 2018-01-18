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

    let saveLogin = UserDefaults.standard

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadLocations()
    }

    func loadLocations() {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let _ = Client.sharedInstance.getStudentLocation({ (results, error) in
            performUIUpdatesOnMain({

                guard error == nil else {
                    Alerts.errorAlert(title: "Failed to Reload!", message: (error?.localizedDescription)!, view: self)
                    return
                }
                
                Student.studentsFromResults(results: results!)
                self.mapView.addAnnotations(self.pinLocations())
                self.mapView.reloadInputViews()
            })
        })
        
    }
    
    @IBAction func logoutTouched(_ sender: Any) {
        Client.sharedInstance.logout({ (success, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("error logging out")
                    print("\(String(describing: error?.localizedDescription))")
                    return
                }
                self.tabBarController?.dismiss(animated: true, completion: nil)
                self.saveLogin.removeObject(forKey: "loggedIn")
            }
        })
    }
    
    @IBAction func refreshTouched(_ sender: Any) {
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
        for student in StudentDataSource.sharedInstance.studentData {

            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)

            let coordinate = CLLocationCoordinate2DMake(lat, long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
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
