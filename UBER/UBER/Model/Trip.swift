//
//  Trip.swift
//  UBER
//
//  Created by MacBook Pro on 15/09/23.
//

import CoreLocation

enum TripStatus: Int {
    case requested
    case accepted
    case driverArrived
    case arriveDestination
    case inProgress
    case completed
}


struct Trip {
     var  pickupCoordinate: CLLocationCoordinate2D!
     var  destinationCoordinate: CLLocationCoordinate2D!
     let passengerUid: String
     var  driverUid: String?
     var  state: TripStatus!
    
    init( passengerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripStatus(rawValue: state)
        }
    }
}
