//
//  CustomPhoneCell.swift
//  RTC_Contacts_Test_App
//
//  Created by Admin on 2/7/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class CustomPhoneCell: UITableViewCell {
    @IBOutlet weak var names: UILabel!
    @IBOutlet weak var phoneNumbers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
