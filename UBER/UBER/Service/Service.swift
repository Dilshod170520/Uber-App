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

struct Servece {
    
    static let shared = Servece()

    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dectionary = snapshot.value as? [String: Any] else { return}
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dectionary)
            completion(user)
        }
    }
    

    
    func fetchDrivers (location: CLLocation, completion: @escaping (User) -> Void) {
        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geoFire.query(at: location, withRadius: 50).observe(.keyEntered) { uid, location in
            fetchUserData(uid: uid) { user in
                var driver = user
                driver.location = location
                completion(driver)
            }
        }
    }
 }
 
