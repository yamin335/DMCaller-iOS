//
//  LocationManager.swift
//  RTCPhone
//
//  Created by Asif Newaz on 13/3/21.
//  Copyright © 2021 Mamun Ar Rashid. All rights reserved.
//

import Foundation
import INTULocationManager

struct LocationModel {
    var lattitude:CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var isInBangladesh: Bool?
    var error: String?
}

class LocationManager {
    class func getLocation(completion: @escaping (LocationModel)->Void) {
        let locationManager = INTULocationManager.sharedInstance()
        var model = LocationModel()
        
        locationManager.requestLocation(withDesiredAccuracy: .city,
                                        timeout: 10.0,
                                        delayUntilAuthorized: true) { (currentLocation, achievedAccuracy, status) in
            if (status == INTULocationStatus.success) {
                let geoCoder = CLGeocoder()
                if let latitude = currentLocation?.coordinate
                    .latitude, let longitude = currentLocation?.coordinate.longitude {
                    
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    model.lattitude = latitude
                    model.longitude = longitude
                    geoCoder.reverseGeocodeLocation(location, completionHandler:
                                                        {
                                                            placemarks, error -> Void in
                                                            
                                                            // Place details
                                                            guard let placeMark = placemarks?.first else { return }
                                                            
                                                            
                                                            // Country
                                                            if let countryCode = placeMark.isoCountryCode, countryCode == "BD" {
                                                                model.isInBangladesh = true
                                                            } else {
                                                                model.isInBangladesh = false
                                                            }
                                                        })
                }
                
                if let description =  currentLocation?.description,  description.lowercased().contains("bangladesh") {
                    model.isInBangladesh = true
                    //return location
                    completion(model)
                } else {
                    model.isInBangladesh = false
                    completion(model)
                }
            }
            else if (status == INTULocationStatus.timedOut) {
                model.error = "Timmed Out."
                completion(model)
            }
            else {
                model.error = "Please enable location service."
                completion(model)
            }
        }
    }
}

extension UIViewController {
    func openLocationSettings() {
        
        let urlString: String = UIApplication.openSettingsURLString
        let settingsAppURL: URL =  URL(string: urlString)!
        
        let alert = UIAlertController(
            title: "Need Location Access.",
            message: "Location access is required for transaction.",
            preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Location Access.",
                                      style: .cancel,
                                      handler: { (alert) -> Void in
                                        UIApplication.shared.open(settingsAppURL,
                                                                  options: [:],
                                                                  completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
