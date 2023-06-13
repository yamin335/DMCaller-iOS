//
//  NetworkSettingsViewController.swift
//  RTCPhone
//
//  Created by Ashraful Islam Masum on 1/26/19.
//  Copyright © 2019 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class NetworkSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var settingOptions = ["Automatic", "WiFi", "Cellular Data"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Network Settings"
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkSettingsCell", for: indexPath) as! NetworkSettingsTableViewCell
        cell.settingsTitles.text = settingOptions[indexPath.row]
        
        cell.tappedForSwitch = { [unowned self] (selectedCell) -> Void in
            let path = tableView.indexPathForRow(at: selectedCell.center)!
            let data = self.settingOptions[path.row]
            //print(selectedCell.settingsSwitch.isOn)
            //print(data)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
