//
//  CallDialedList.swift
//  RTCPhone
//
//  Created by Admin on 1/8/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class CallDialedList: UITableViewCell {

    @IBOutlet weak var contactNumber: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
