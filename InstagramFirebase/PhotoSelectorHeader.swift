//
//  PhotoSelectorHeader.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/5/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class PhotoSelectorHeader: BaseCell {
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(photoImageView)
        photoImageView.fillSuperview()
    }
}
