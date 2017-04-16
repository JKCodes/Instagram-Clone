//
//  UserSearchCell.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/16/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserSearchCell: BaseCell {
    
    fileprivate let cellSpacing: CGFloat = 8
    fileprivate let profileImageHeight: CGFloat = 50
    fileprivate let separatorHeight: CGFloat = 0.5
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            profileImageView.loadImage(urlString: profileImageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(separatorView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: cellSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageHeight, heightConstant: profileImageHeight)
        profileImageView.anchorCenterYToSuperview()
        profileImageView.layer.cornerRadius = profileImageHeight / 2
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: cellSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        separatorView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: separatorHeight)        
    }
    
}
