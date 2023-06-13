//
//  LoginResponse.swift
//  RTCPhone
//
//  Created by Asif Newaz on 13/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    var name: String?
    var company_uniqueid: String?
    var extensions: String?
    var secret: String?
    var server_ip: String?
    var server_port: String?
    var company_key: String?
    var company_key_date: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case company_uniqueid = "company_uniqueid"
        case extensions = "extension"
        case secret = "secret"
        case server_ip = "server_ip"
        case server_port = "server_port"
        case company_key = "company_key"
        case company_key_date = "company_key_date"
    }
}

struct RegistrationResponse: Codable {
    var success: String?
    var error: String?
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case error = "error"
    }
}


