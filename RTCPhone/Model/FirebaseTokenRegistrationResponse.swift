//
//  FirebaseTokenRegistrationResponse.swift
//  RTCPhone
//
//  Created by Md. Yamin on 11/21/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation

struct FCMTokenRegisterRequest: Codable {
    let userid: String
    let apikey: String
    let mobile_no: String
    let company: String
    let token: String
    let imei_number: String
    let latitude: Double
    let longitude: Double
    let platform: String
}

struct FCMTokenRegistrationResponse: Codable {
    let messages: String?
}
