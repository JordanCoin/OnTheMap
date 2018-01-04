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
    
    @IBOutlet weak var findLocButton: BorderedButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields([locationTextField, linkTextField])
    }
    
    @IBAction func findLocationTouched(_ sender: Any) {
        if credentialsFilled() {
            findLoc()
        }
    }
    
    func findLoc() {
        guard let savedlink = linkTextField.text, let location = locationTextField.text else {
            let alert = Alerts.errorAlert(title: "Link Invalid", message: "Your link is not a valid url")
            present(alert, animated: true, completion: nil)
            return
        }
        geocode.geocodeAddressString(location, completionHandler: { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, processedLink: savedlink, error: error, { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "presentLocSegue", sender: self)
                    }
                }
            })
        })
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, processedLink: String, error: Error?, _ completion: @escaping (_ success: Bool) -> Void) {
        
        performUIUpdatesOnMain {
            
            if let error = error {
                let alert = Alerts.errorAlert(title: "Unable to Forward Geocode Address", message: "Unable to Find Location for Address \(error.localizedDescription)")
                self.present(alert, animated: true, completion: nil)
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
                    completion(true)
                } else {
                    let alert = Alerts.errorAlert(title: "No Matching Location Found", message: "Unable to Find Location for Address")
                    self.present(alert, animated: true, completion: nil)
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
            let alert = Alerts.errorAlert(title: "Error Finding Location", message: "You need to enter a location and a link to find your location!")
            present(alert, animated: true, completion: nil)
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
