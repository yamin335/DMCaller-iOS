//
//  RingtoneTableViewCell.swift
//  RTCPhone
//
//  Created by Md. Yamin on 4/6/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class RingtoneTableViewCell: UITableViewCell {

    @IBOutlet weak var ringtoneTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
