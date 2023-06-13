//
//  DialerCallList.swift
//  RTCPhone
//
//  Created by Admin on 4/8/18.
//  Copyright © 2018 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class DialerCallList: UITableViewCell {
    
    var tappedForAddBtn: ((DialerCallList) -> Void)?

    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var dialedImageView: UIImageView!
    @IBOutlet weak var dialedPhoneNumber: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var time: UILabel!
    //    @IBAction func addBtnAction(_ sender: UIButton) {
//        tappedForAddBtn?(self)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
