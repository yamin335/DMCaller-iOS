//
//  APIServiceManager.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import Alamofire

class APIServiceManager {
    
    //MARK: Login API
    class func login(mobile: String, companyID: String, password: String,uuid: String, lat: Double, lon: Double, completion:@escaping (APIResult<LoginResponse, Error>)->Void) {
        
        let endPoint = APIEndPoint.login(mobile: mobile, companyID: companyID, password: password, uuid: uuid, lat: lat, lon: lon)
        print(endPoint.path)
        AFManager.requestWith(url: endPoint.path, method: endPoint.method, parameters: [:], encoding: URLEncoding.default, headers: [:]) { (result: APIResult<LoginResponse, Error>) in
            completion(result)
        }
    }
    
    //MARK: Registration API
    class func register(mobile: String, name: String, companyID: String, password: String, email: String, uuid: String = UUID().uuidString, lat: Double, lon: Double, completion:@escaping (APIResult<RegistrationResponse, Error>)->Void) {
        
        let endPoint = APIEndPoint.register(mobile: mobile, name: name, companyID: companyID, password: password, email:email, uuid: uuid, lat: lat, lon: lon)
        AFManager.requestWith(url: endPoint.path, method: endPoint.method, parameters: [:], encoding: URLEncoding.default, headers: [:]) { (result: APIResult<RegistrationResponse, Error>) in
            completion(result)
        }
    }
    
    //MARK: Registration API
    class func fcmTokenRegistration(requestBody: FCMTokenRegisterRequest, completion:@escaping (APIResult<FCMTokenRegistrationResponse, Error>)->Void) {
        
        let endPoint = APIEndPoint.fcmTokenRegister(requestBody: requestBody)
        print(endPoint.path)
        AFManager.requestWith(url: endPoint.path, method: endPoint.method, parameters: [:], encoding: URLEncoding.default, headers: [:]) { (result: APIResult<FCMTokenRegistrationResponse, Error>) in
            completion(result)
        }
    }
    //MARK: Login API
//    class func login(mobile: String, companyID: String, password: String,uuid: String, lat: Double, lon: Double, completion:@escaping (APIResult<LoginResponse, Error>)->Void) {
//
//        let endPoint = APIEndPoint.login(mobile: mobile, companyID: companyID, password: password, uuid: uuid, lat: lat, lon: lon)
//        print(endPoint.path)
//        AFManager.requestWith(url: endPoint.path, method: endPoint.method, parameters: [:], encoding: URLEncoding.default, headers: [:]) { (result: APIResult<LoginResponse, Error>) in
//            completion(result)
//        }
//    }
}
