//
//  User.swift
//  UBER
//
//  Created by MacBook Pro on 08/09/23.
//
import Foundation
import CoreLocation

struct User {
    let fullname: String
    let email: String
    let accountType: Int
    let uid: String
    var location: CLLocation?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? " "
        self.email = dictionary["email"] as? String ?? " "
        self.accountType = dictionary["accountType"] as? Int ?? 0  
    }
}
