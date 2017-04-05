//
//  Post.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/5/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
