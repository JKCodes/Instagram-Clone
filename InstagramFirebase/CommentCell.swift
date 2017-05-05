//
//  CommentCell.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 5/3/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class CommentCell: BaseCell {
    
    fileprivate let cellSpacing: CGFloat = 8
    fileprivate let imageLength: CGFloat = 40
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
                        
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: " " + comment.text, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
            
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        return tv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 230, g: 230, b: 230)
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.layer.cornerRadius = imageLength / 2
        
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(separatorView)
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: separatorView.topAnchor, right: rightAnchor, topConstant: cellSpacing / 2, leftConstant: cellSpacing / 2, bottomConstant: 0, rightConstant: cellSpacing / 2, widthConstant: 0, heightConstant: 0)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: cellSpacing, leftConstant: cellSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: imageLength, heightConstant: imageLength)
        separatorView.anchor(top: nil, left: textView.leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
    }
}
