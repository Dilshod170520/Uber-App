//
//  User.swift
//  UBER
//
//  Created by MacBook Pro on 08/09/23.
//

struct User {
    private(set) public var fullname: String
    private(set) public var email: String
    private(set) public var accountType: Int
    
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? " "
        self.email = dictionary["email"] as? String ?? " "
        self.accountType = dictionary["accountType"] as? Int ?? 0  
    }
}
