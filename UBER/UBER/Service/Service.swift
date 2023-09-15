//
//  Service.swift
//  UBER
//
//  Created by MacBook Pro on 08/09/23.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS =  DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    static let shared = Service()
     func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dectionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dectionary)
            completion(user)
        }
    }
         
    func fetchDrivers (location: CLLocation, completion: @escaping (User) -> Void) {
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
         geoFire.query(at: location, withRadius: 50).observe(.keyMoved) { uid, location in
            fetchUserData(uid: uid) { user in
                var driver = user
                driver.location = location
                completion(driver)
            }
        }
    }
    func uploudTrip(_ pickupCoordinate: CLLocationCoordinate2D, _ distanetionCoordinate: CLLocationCoordinate2D, completion: @escaping(Error? , DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid  else { return}
        
        let pickupArray = [pickupCoordinate.latitude, pickupCoordinate.longitude]
        let distanetionArray = [distanetionCoordinate.latitude, distanetionCoordinate.longitude]
        
        let value = ["pickupcoordinate": pickupArray,
                     "distanitionCoordinate": distanetionArray, 
                     "state": TripStatus.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(value, withCompletionBlock: completion)
         
    }
}
