//
//  NetworkSettingsTableViewCell.swift
//  RTCPhone
//
//  Created by Ashraful Islam Masum on 1/26/19.
//  Copyright © 2019 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class NetworkSettingsTableViewCell: UITableViewCell {
    
    var tappedForSwitch: ((NetworkSettingsTableViewCell) -> Void)?

    @IBOutlet weak var settingsTitles: UILabel!
    @IBOutlet weak var settingsSwitch: UISwitch!
    @IBAction func settingsSwitchAction(_ sender: UISwitch) {
        //print(sender)
        tappedForSwitch?(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
