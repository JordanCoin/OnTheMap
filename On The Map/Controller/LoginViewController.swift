//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/2/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var locations: StudentLocation!
//    var sessionID: String? = nil

    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        
        configureTextFields([emailTextField, passwordTextField], clearText: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUIEnabled(false)
        configureTextFields([emailTextField, passwordTextField], clearText: true)
    }
    
    // Login Actions
    
    @IBAction func loginTouched(_ sender: Any) {
        login()
    }
    
    func login() {
        if credentialsFilled() {
            if let email = emailTextField.text, let password = passwordTextField.text {
                
                // Get Session ID to authenticate login
                Client.sharedInstance().getSessionID(email, password, { (success, sessionID, errorString) in
                    performUIUpdatesOnMain {
                        
                        if success {
                            Client.sharedInstance().sessionID = sessionID
                            let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentNavigationController") as! UINavigationController
                            self.present(controller, animated: true, completion: nil)
                            
                        } else {
                            let alert = Alerts.errorAlert(title: "Error logging in", message: errorString)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    func credentialsFilled() -> Bool {
        if emailTextField.text != "" && passwordTextField.text != "" {
            return true
        } else {
            let alert = Alerts.errorAlert(title: "Error logging in", message: "Your login information is invalid.")
            present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    func setUIEnabled(_ enabled: Bool) {
        loginButton.isEnabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }

    @IBAction func signUpTouched(_ sender: Any) {
        performSegue(withIdentifier: "signUpIdentifier", sender: self)
    }
}

// MARK: - UITextFieldDelegate Methods & Related Methods

extension LoginViewController: UITextFieldDelegate {
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            setUIEnabled(false)
            return
        }
        setUIEnabled(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
            login()
        }
        return true
    }
    
    func configureTextFields(_ textFields: [UITextField],  clearText: Bool) {
        for textField in textFields {
            textField.delegate = self
            textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
            
            if clearText == true {
                textField.text = ""
            }
        }
    }
}
