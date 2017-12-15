//
//  LocationTableViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/19/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTable()
    }
    
    func loadTable() {
        let _ = Client.sharedInstance().taskForGETMethod(Client.sharedInstance().sessionID, "\(Client.Constants.Parse.baseURL)\(Client.Constants.Parse.StudentLocation)", handler: { (success, errorString) in
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
        let url = URL(string: StudentLocationCollection.totalLocations[(indexPath as NSIndexPath).row].mediaURL!)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }

}
