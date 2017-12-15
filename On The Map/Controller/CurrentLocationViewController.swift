//
//  CurrentLocationViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 12/4/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationViewController: UIViewController, MKMapViewDelegate {

    let studentLocation: StudentLocation! = nil
    var longitude = Double()
    var latitude = Double()
    var link = String()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: BorderedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("long: \(longitude) lat: \(latitude) link: \(link)")
        mapView.delegate = self
        mapView.reloadInputViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(self.pinLocation())
        }
    }
    
    func pinLocation() -> MKAnnotation {
        
        let annotation = MKPointAnnotation()

        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        

        let name = ("\(studentLocation.firstName) \(studentLocation.lastName)")
        
        annotation.coordinate = coordinate
        annotation.title = name
        annotation.subtitle = link
        return annotation
    }
    
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
 
    @IBAction func finishButtonTouched(_ sender: Any) {
        
        let _ = Client.sharedInstance().taskForPOSTMethod(Client.sharedInstance().sessionID!, latitude, longitude, link) { (success, errorString) in
            if success {
                performUIUpdatesOnMain({
                    print("test passed")
                })
            } else {
                let alert = Alerts.errorAlert(title: "Error posting location!", message: errorString)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
