//
//  NotificationVC.swift
//  RTCPhone
//
//  Created by Md. Yamin on 4/5/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    private let notificationList = [NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival "), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival"), NotificationMsg(title: "New Offer", message: "Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival Offer for new year festival")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.title.text = notificationList[indexPath.row].title
        cell.message.text = notificationList[indexPath.row].message
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
