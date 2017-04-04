//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserProfileHeader: BaseCell {
    
    fileprivate let cellOffset: CGFloat = 12
    fileprivate let profileImageLength: CGFloat = 80
    fileprivate static let profileImageRadius: CGFloat = 40
    
    var user: User? {
        didSet {
            setupProfileImage()
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = profileImageRadius
        return iv
    }()
    
    override func setupViews() {
       super.setupViews()
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: cellOffset, leftConstant: cellOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
    }
    
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        
        profileImageView.loadImageUsingCache(urlString: profileImageUrl)
    }
}
