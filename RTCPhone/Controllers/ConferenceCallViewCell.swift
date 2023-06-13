//
//  ConferenceCallViewCell.swift
//  RTCPhone
//
//  Created by Md. Yamin on 5/11/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit

class ConferenceCallViewCell: UITableViewCell {

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var btnPauseCall: UIButton!
    
    var call: ConferenceCall? = nil
    var isCallPaused = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if isCallPaused {
            btnPauseCall.tintColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
        } else {
            btnPauseCall.tintColor = .black
        }
    }

    @IBAction func pauseCall(_ sender: Any) {
        isCallPaused = !isCallPaused
        let linphoneManager = LinphoneManager()
        
        guard let call = call?.call else {
            return
        }
        
        if isCallPaused {
            linphoneManager.pauseCall(call: call!)
            btnPauseCall.tintColor = #colorLiteral(red: 0.1843137255, green: 0.5725490196, blue: 0.8156862745, alpha: 1)
        } else {
            linphoneManager.resumeCall(call: call!)
            btnPauseCall.tintColor = .black
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
