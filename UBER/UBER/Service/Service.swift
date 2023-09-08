//
//  Service.swift
//  UBER
//
//  Created by MacBook Pro on 08/09/23.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Servece {
    
    static let shared = Servece()
    let currentUID = Auth.auth().currentUser?.uid
    func fetchUserData(completion: @escaping(User) -> Void) {
       
        REF_USERS.child(currentUID!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dectionary = snapshot.value as? [String: Any] else { return}
             let user = User(dictionary: dectionary)
            completion(user)
        }
    }
}
