//
//  Comment.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 5/3/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
