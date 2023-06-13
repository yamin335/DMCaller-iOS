//
//  NotificationMsg.swift
//  RTCPhone
//
//  Created by Md. Yamin on 4/5/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import Foundation

struct NotificationMsg: Codable {
    var title: String?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case message = "message"
    }
}
