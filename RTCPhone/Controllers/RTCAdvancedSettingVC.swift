//
//  RTCAdvancedSettingVC.swift
//  RTCPhone
//
//  Created by Admin on 8/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class RTCAdvancedSettingVC: UIViewController {
    var bookMarksArray = [MoreOptionsManager(optionName: "Bookmarks", icon: "bookmark-1"), MoreOptionsManager(optionName: "Events", icon: "event"), MoreOptionsManager(optionName: "Talk", icon: "talk-1")]
    var moreArray = [MoreOptionsManager(optionName: "Find Friends", icon: "search_friend"), MoreOptionsManager(optionName: "Add a Bussiness", icon: "add_business"), MoreOptionsManager(optionName: "Support", icon: "support-1")]
    @IBOutlet weak var moreOptionsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "More Options"
        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension RTCAdvancedSettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        return "More"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bookMarksArray.count
        }
        return moreArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreOptionsCell", for: indexPath) as! MoreOptionsCustomCell
        cell.iconView.image = UIImage(named: bookMarksArray[indexPath.row].icon!)
        cell.moreOptions.text = bookMarksArray[indexPath.row].optionName
        
        if indexPath.section == 1 {
            cell.iconView.image = UIImage(named: moreArray[indexPath.row].icon!)
            cell.moreOptions.text = moreArray[indexPath.row].optionName
        }
        return cell
    }
    
    
}
