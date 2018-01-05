//
//  LocationTableViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/19/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
        
    var students = Student()
    let loginSave = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTable()
    }
    
    func loadTable() {
        let _ = Client.sharedInstance.getStudentLocation({ (value, errorString) in
            
            guard let value = value else {
                errorAlert(title: "Failed to Reload!", message: "Check your connection, we could not reload the information. \(String(describing: errorString))", view: self)
                return
            }
            
            self.students = value
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }

    @IBAction func logoutTouched(_ sender: Any) {
        Client.sharedInstance.logout({ (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.tabBarController?.dismiss(animated: true, completion: nil)
                    self.loginSave.removeObject(forKey: "loggedIn")
                    Client.sharedInstance.userKey.removeObject(forKey: "key")
                }
            }
        })
    }
    
    @IBAction func refreshTouched(_ sender: Any) {
        loadTable()
    }
    
    @IBAction func addTouched(_ sender: Any) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "LocationNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "locationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LocationTableViewCell
        let student = students.array[indexPath.row]

        cell.fullNameLbl.text = ("\(student.firstName) \(student.lastName)")
        cell.linkLbl.text = "\(student.mediaURL)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students.array[indexPath.row]
        if let url = URL(string: student.mediaURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            errorAlert(title: "Unable to load URL", message: "Looks like this is a invalid URL, try another!", view: self)
        }
    }

}
