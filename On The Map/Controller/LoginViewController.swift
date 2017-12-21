//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/2/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

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
        performUIUpdatesOnMain {
            self.login()
        }
    }
    
    func login() {
        if credentialsFilled() {
            if let username = emailTextField.text, let password = passwordTextField.text {
                
                Client.sharedInstance().getSessionID(username, password) { (sessionID, error) in
                    guard (error == nil) else {
                        let alert = Alerts.errorAlert(title: "Error logging in", message: error)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    guard let userID = sessionID else {
                        let alert = Alerts.errorAlert(title: "Error logging in", message: error)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.completeLogin(userID: userID)
                }
            }
        }
    }
    
    func completeLogin(userID: String) {
        
        Client.sharedInstance().getUdacityUserInfo(userID: userID) { (result, error) in
            guard (error == nil) else {
                let alert = Alerts.errorAlert(title: "Error logging in", message: error)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let user = result else {
                let alert = Alerts.errorAlert(title: "Error logging in", message: "Could not retrieve the custom USER struct from the Udacity users API")
                self.present(alert, animated: true, completion: nil)
                return
            }

            // save the user and show the main nav bar controller
            self.appDelegate.user = user
            self.showMainTabController()
        }
    }
    
    func showMainTabController() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "StudentMainTabBarController") as! UITabBarController
        present(controller, animated: true, completion: nil)
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
