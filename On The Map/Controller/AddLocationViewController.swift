//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 12/4/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    
    lazy var geocode = CLGeocoder()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var longitude: Double? = nil
    var latitude: Double? = nil
    var link: String? = nil
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var findLocButton: BorderedButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        configureTextFields([locationTextField, linkTextField])
        
        activity.layer.cornerRadius = 10
        activity.frame = activity.frame.insetBy(dx: -10, dy: -10)
        activity.center = self.view.center
        activity.tag = 1001
        view.addSubview(activity)
    }
    
    @IBAction func findLocationTouched(_ sender: Any) {
        if credentialsFilled() {
            findLoc()
        }
    }
    
    func findLoc() {
        guard let savedlink = linkTextField.text, let location = locationTextField.text else {
            Alerts.errorAlert(title: "Link Invalid", message: "Your link is not a valid url", view: self)
            return
        }
        
        activity.startAnimating()
        
        geocode.geocodeAddressString(location, completionHandler: { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, processedLink: savedlink, error: error, { (success) in
                
                if success {
                    DispatchQueue.main.async {
                        self.activity.stopAnimating()
                        self.performSegue(withIdentifier: "presentLocSegue", sender: self)
                    }
                }
            })
        })
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, processedLink: String, error: Error?, _ completion: @escaping (_ success: Bool) -> Void) {
        
        performUIUpdatesOnMain {
            
            if let error = error {
                print(error.localizedDescription)
                self.activity.stopAnimating()
                Alerts.errorAlert(title: "Unable to Forward Geocode Address", message: "Could not pin your location from the location provided, try again.", view: self)
            } else {
                var location: CLLocation?
                
                if let placemarks = placemarks, placemarks.count > 0 {
                    location = placemarks.first?.location
                }
                
                if let location = location {
                    let coordinate = location.coordinate
                    self.link = processedLink
                    self.latitude = coordinate.latitude
                    self.longitude = coordinate.longitude
                    self.activity.stopAnimating()
                    completion(true)
                }
            }
        }
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if identifier == "presentLocSegue" {
            if let currentLocVC = storyboard?.instantiateViewController(withIdentifier: "CurrentLocationViewController") as? CurrentLocationViewController, let location = locationTextField.text, let user = appDelegate.user {
                
                currentLocVC.finalInit(user: user, location: location, mediaURL: link!, longitude: longitude!, latitude: latitude!)
                navigationController?.pushViewController(currentLocVC, animated: true)
            }
        }
    }
    
    func credentialsFilled() -> Bool {
        if locationTextField.text != "" && linkTextField.text != "" {
            return true
        } else {
            Alerts.errorAlert(title: "Error Finding Location", message: "You need to enter a location and a link to find your location!", view: self)
            return false
        }
    }
    
    @IBAction func cancelTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            DispatchQueue.main.async {
                self.linkTextField.becomeFirstResponder()
            }
        } else {
            DispatchQueue.main.async {
                self.linkTextField.resignFirstResponder()
            }
            findLoc()
        }
        return true
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
    }
    
    func configureTextFields(_ textFields: [UITextField]) {
        for textField in textFields {
            textField.delegate = self
            textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        }
    }
}
