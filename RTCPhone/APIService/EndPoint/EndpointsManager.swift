//
//  EndpointsManager.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import Alamofire

enum APIEndPoint: EndPointCompatible {
    case login(mobile: String, companyID: String, password: String,uuid: String, lat: Double, lon: Double)
    
    case register(mobile: String, name: String, companyID: String, password: String,email: String, uuid: String, lat: Double, lon: Double)
    
    case fcmTokenRegister(requestBody: FCMTokenRegisterRequest)
    
    var method: HTTPMethod {
        switch self {
        default :
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .login(let mobile, let companyID, let password,let uuid, let lat, let lon):
            return APIPath.basePath(path: EndPointSubURLs.login.rawValue).url + "/?userid=\(APIConfiguration.apiUserID)&apikey=\(APIConfiguration.apiKEY)&mobile_no=\(mobile)&name=&company=\(companyID)&password=\(password)&email=&imei_number=\(uuid)&latitude=\(lat)&longitude=\(lon)"
        
        case .register(let mobile, let name, let companyID, let password, let email, let uuid, let lat, let lon):
            return APIPath.basePath(path: EndPointSubURLs.registerPath.rawValue).url + "/?userid=\(APIConfiguration.apiUserID)&apikey=\(APIConfiguration.apiKEY)&mobile_no=\(mobile)&name=\(name)&company=\(companyID)&password=\(password)&email=\(email)&imei_number=\(uuid)&latitude=\(lat)&longitude=\(lon)&platform=ios"
            
        case .fcmTokenRegister(let requestBody):
            return APIPath.basePath(path: EndPointSubURLs.fcmTokenRegistration.rawValue).url + "/?userid=\(requestBody.userid)&apikey=\(requestBody.apikey)&mobile_no=\(requestBody.mobile_no)&company=\(requestBody.company)&token=\(requestBody.token)&imei_number=\(requestBody.imei_number)&latitude=\(requestBody.latitude)&longitude=\(requestBody.longitude)&platform=\(requestBody.platform)"
        
        }
    }
    
    var query: [String: Any]  {
        switch self {
        case .login(_,_,_,_,_,_):
            return [:]
        case .register(_,_,_,_,_,_,_,_):
            return [:]
        case .fcmTokenRegister(_):
            return [:]
        }
    }
}





