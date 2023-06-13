//
//  AFManager.swift
//  RTCPhone
//
//  Created by Asif Newaz on 12/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import Alamofire

public enum APIResult<Response,Value> {
    case success(Response)
    case failure(AppError)
}

class AFManager {
    static var sessionManager: SessionManager?
    
    class func createAlamofireSession() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        let sessionManager = SessionManager(configuration: configuration)
        AFManager.sessionManager = sessionManager
    }
    
    class func requestWith<T: Codable>(url :String, method: HTTPMethod, parameters: [String:Any], encoding: ParameterEncoding, headers: [String:String], completion: @escaping (APIResult<T, Error>) -> Void) {
        sessionManager?.request(url,method: method,parameters: parameters,encoding: encoding, headers: headers).responseData(completionHandler: {response in
            switch response.result{
            case .success(let res):
                if let code = response.response?.statusCode{
                    switch code {
                    case 200...299:
                        do {
                            let object = try JSONDecoder().decode(T.self, from: res)
                            completion(.success(object))
                        } catch let error {
                            print(String(data: res, encoding: .utf8) ?? "nothing received")
                            completion(.failure(.dataParsingError(error)))
                        }
                    case 400:
                        completion(.failure(.badRequest))
                    case 401:
                        completion(.failure(.unauthorised))
                    case 403:
                        completion(.failure(.notAllowed))
                    case 404:
                        completion(.failure(.notFound))
                    case 500:
                        completion(.failure(.internalServerError))
                    default:
                        let error = NSError(domain: response.debugDescription, code: code, userInfo: response.response?.allHeaderFields as? [String: Any])
                        completion(.failure(.error(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(.error(error)))
            }
        })
    }
}
