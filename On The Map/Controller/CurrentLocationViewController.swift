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

    var user: User?
    var link: String?
    var location: String?
    var longitude = Double()
    var latitude = Double()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: BorderedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(self.pinLocation())
        }
    }
    
    func finalInit(user: User, location: String, mediaURL: String) {
        self.user = user
        self.location = location
        self.link = mediaURL
    }
    
    func pinLocation() -> MKAnnotation {
        
        let annotation = MKPointAnnotation()

        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        
        var name: String? = nil
        
        if let student = StudentLocationCollection.totalLocations.first {
            name = ("\(student.firstName) \(student.lastName)")
        }
        
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
        postStudentLocation()
    }
    
    func postStudentLocation() {
        
        guard let userID = user?.userId,
            let firstName = user?.firstName,
            let lastName = user?.lastName,
            let mediaURL = link,
            let location = location
            else {
                let alert = Alerts.errorAlert(title: "Error posting Data!", message: "Could not unwrap properties passed in")
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        let _ = Client.sharedInstance().postStudentLocation(userId: userID, firstName: firstName, lastName: lastName, mediaURL: mediaURL, latitude: latitude, longitude: longitude, location: location) { (results, errorString) in
            
            guard (errorString == nil) else {
                let alert = Alerts.errorAlert(title: "Sorry, but we could not successfully post your location", message: errorString)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // dismiss the information posting view
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
