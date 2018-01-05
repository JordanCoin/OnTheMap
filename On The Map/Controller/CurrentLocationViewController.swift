//
//  CurrentLocationViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 12/4/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.

import UIKit
import MapKit

class CurrentLocationViewController: UIViewController, MKMapViewDelegate {

    var user: User?
    var link: String?
    var location: String?
    var longitude: Double?
    var latitude: Double?
    var students = [Student]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: BorderedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.addAnnotation(pinLocation())
    }
    
    func finalInit(user: User, location: String, mediaURL: String, longitude: Double, latitude: Double) {
        self.user = user
        self.location = location
        self.link = mediaURL
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func pinLocation() -> MKAnnotation {
        
        let annotation = MKPointAnnotation()

        let lat = CLLocationDegrees(latitude!)
        let long = CLLocationDegrees(longitude!)
        
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        
        annotation.coordinate = coordinate
        annotation.title = ("\(String(describing: user!.firstName)) \(String(describing: user!.lastName))")
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
        performUIUpdatesOnMain {
            guard let userID = self.user?.userId,
                let firstName = self.user?.firstName,
                let lastName = self.user?.lastName,
                let mediaURL = self.link,
                let location = self.location,
                let latitude = self.latitude,
                let longitude = self.longitude
                else {
                    errorAlert(title: "Error posting Data!", message: "Could not unwrap properties passed in", view: self)
                    return
            }
            
            let _ = Client.sharedInstance.postStudentLocation(userId: userID, firstName: firstName, lastName: lastName, mediaURL: mediaURL, latitude: latitude, longitude: longitude, location: location) { (results, errorString) in
                
                guard (errorString == nil) else {
                    errorAlert(title: "Sorry, but we could not successfully post your location", message: errorString!, view: self)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
