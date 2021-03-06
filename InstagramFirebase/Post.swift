//
//  Post.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/5/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation

struct Post {
    
    var id: String?
    
    let imageUrl: String
    let user: User
    let caption: String
    let creationDate: Date
    
    var hasLiked = false
    
    init(user: User, dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.creationDate = Date(timeIntervalSince1970: dictionary["creationDate"] as? Double ?? 0)
    }
}
