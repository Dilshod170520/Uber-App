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
  
    func fetchUserData(completion: @escaping(User) -> Void) {
        guard  let currentUID = Auth.auth().currentUser?.uid else { return}
       
        REF_USERS.child(currentUID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dectionary = snapshot.value as? [String: Any] else { return}
             let user = User(dictionary: dectionary)
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation) {
        let  geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)

        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
//            geoFire.query(at: location, withRadius: 50).observe(.keyMoved) {uid , location in
//           
//                
//            }
//            geoFire.query(at: location, withRadius: 50).observe(.keyEntered) {( uid, locat) in
//                print("Debug: user uid: \( uid)")
//                print("Debug: user location cordenate: \(locat.)")
//            }
        }
    }
    
//    func fetchDrivers(location: CLLocation) {
//        let geoFire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
//
//        // Add an observer for .childAdded event to track changes in driver locations
//        REF_DRIVER_LOCATIONS.observe(.childAdded) { (snapshot) in
//
//            // Handle changes to driver locations here
//            // You can access the snapshot and extract relevant data
//            // e.g., snapshot.key and snapshot.value
//        }
//
//        // Set up the GeoFire query and its observer as before
////        geoFire.query(at: location, withRadius: 50).observe(.keyEntered) { (uid, location) in
////            print("Debug: user uid: \(uid)")
////            print("Debug: user location coordinate: \(location)")
////        }
//    }

 }
 
