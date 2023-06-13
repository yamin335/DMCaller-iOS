//
//  HelpViewController.swift
//  RTCPhone
//
//  Created by Md. Yamin on 4/5/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var helpMeenuTableView: UITableView!
    @IBOutlet weak var appVersion: UILabel!
    
    var helpMenuItems = [
        "Company", "FAQ",
        "Terms & Conditions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        appVersion.text = "App version \(AppGlobalValues.appVersion)"
    }

}

extension HelpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpMenuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpMenuTableViewCell", for: indexPath) as! HelpMenuTableViewCell
        cell.menuTitle.text = helpMenuItems[indexPath.row]
        if indexPath.row == helpMenuItems.count - 1 {
            cell.separatorInset.left = cell.bounds.size.width + 200
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "showCompanyDetailsSegue", sender: self)
                break
                
            case 1:
                performSegue(withIdentifier: "showCompanyDetailsSegue", sender: self)
                break
                
            case 2:
                performSegue(withIdentifier: "showCompanyDetailsSegue", sender: self)
                break
                
            default:
                print("Error")
            }
        
    }
    
}
