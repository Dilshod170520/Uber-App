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
    case isProgress
    case completed
}

struct Trip {
    private(set) public var  pickupCoordinate: CLLocationCoordinate2D!
    private(set) public var  distanitionCoordinate: CLLocationCoordinate2D!
    private(set) public var  passengerUid: String
    private(set) public var  driverUid: String?
    private(set) public var  state: TripStatus!
    
    init( passengerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let pickupcoordinates = dictionary["pickupcoordinate"] as? NSArray {
            guard let lat = pickupcoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupcoordinates[1] as? CLLocationDegrees else { return}
            self.pickupCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destanetioncoordinate = dictionary["distanitionCoordinate"]  as? NSArray {
            guard let lat = destanetioncoordinate[0] as? CLLocationDistance else {return}
            guard let long = destanetioncoordinate[1] as? CLLocationDegrees else { return}
            self.distanitionCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
       if let state = dictionary["state"] as? Int {
            self.state = TripStatus(rawValue: state)
        }
    }
}
