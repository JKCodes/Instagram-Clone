//
//  HomePostCell.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/7/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomePostCell: BaseCell {
    
    var post: Post? {
        didSet {
            guard let urlString = post?.imageUrl else { return }
            
            photoImageView.loadImageUsingCache(urlString: urlString)
        }
    }
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(photoImageView)
        
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
}
