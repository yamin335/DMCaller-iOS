//
//  NewMemberTableViewCell.swift
//  RTCPhone
//
//  Created by Admin on 4/7/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class NewMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var names: UILabel!
    @IBOutlet weak var phoneNumbers: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
