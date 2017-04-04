//
//  User.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
