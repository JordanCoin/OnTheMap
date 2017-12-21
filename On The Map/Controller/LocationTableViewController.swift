//
//  LocationTableViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/19/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    var students: Student!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTable()
    }
    
    func loadTable() {
        let _ = Client.sharedInstance().taskForGETMethod("\(Constants.Methods.ParseStudentLocation)", completionHandlerGET: { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                let alert = Alerts.errorAlert(title: "Check your Network!", message: errorString)
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
        let _ = Client.sharedInstance().putStudentLocation(userId: (appDelegate.user?.userId)!, completionHandlerForPUTStudentLoc: { (value, errorString) in
            
            performUIUpdatesOnMain {
                print("testTable")
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [NSIndexPath(row: StudentLocationCollection.totalLocations.count-1, section: 0) as IndexPath], with: .automatic)
                self.tableView.endUpdates()
            }
            
            
            if value != nil {
            } else {
                let message = (errorString) ?? "Check your connection, we could not reload the information."
                let alert = Alerts.errorAlert(title: "Failed to Reload!", message: message)
                self.present(alert, animated: true, completion: nil)
            }
        })
        loadTable()
    }
    
    @IBAction func addTouched(_ sender: Any) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "LocationNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationCollection.count()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "locationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LocationTableViewCell
        
        cell.fullNameLbl.text = ("\(String(describing: StudentLocationCollection.totalLocations[(indexPath as NSIndexPath).row].firstName)) \(String(describing: StudentLocationCollection.totalLocations[(indexPath as NSIndexPath).row].lastName))")
        cell.linkLbl.text = StudentLocationCollection.totalLocations[(indexPath as NSIndexPath).row].mediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: StudentLocationCollection.totalLocations[(indexPath as NSIndexPath).row].mediaURL!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = Alerts.errorAlert(title: "Unable to load URL", message: "Looks like they used a invalid URL, try another!")
            present(alert, animated: true, completion: nil)
        }
    }

}
