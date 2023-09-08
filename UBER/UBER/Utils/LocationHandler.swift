//
//  LocationHandler.swift
//  UBER
//
//  Created by MacBook Pro on 08/09/23.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
     static let shared = LocationHandler()
    var locationManager: CLLocationManager! = nil
    var location: CLLocation!
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self 
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
