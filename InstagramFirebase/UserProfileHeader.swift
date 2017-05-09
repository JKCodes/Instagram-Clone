//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

protocol UserProfileHeaderDelegate: class {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: BaseCell {
    
    fileprivate let contentOffset: CGFloat = 12
    fileprivate let profileImageLength: CGFloat = 80
    fileprivate static let profileImageRadius: CGFloat = 40
    fileprivate let stackViewHeight: CGFloat = 50
    fileprivate let editProfileButtonHeight: CGFloat = 34
    fileprivate let dividerHeight: CGFloat = 0.5
    
    var user: User? {
        didSet {
            setupProfileImage()
            
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
            
        }
    }
    
    weak var delegate: UserProfileHeaderDelegate?
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = profileImageRadius
        return iv
    }()
    
    lazy var gridButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    let bookMarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "temporary"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSForegroundColorAttributeName: UIColor.lightGray, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override func setupViews() {
       super.setupViews()
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(editProfileFollowButton)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: contentOffset, leftConstant: contentOffset, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageLength, heightConstant: profileImageLength)
   
        setupBottomToolBar()
        setupUsernameLabel()
        setupUserStatsView()
        setupEditProfileButton()
    }
    
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        
        profileImageView.loadImage(urlString: profileImageUrl)
    }
    
    fileprivate func setupBottomToolBar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookMarkButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: stackViewHeight)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: dividerHeight)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: dividerHeight)
    }
    
    fileprivate func setupUsernameLabel() {
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, topConstant: contentOffset / 3, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: contentOffset, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
    }
    
    fileprivate func setupEditProfileButton() {
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: editProfileButtonHeight)
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = AuthenticationService.shared.currentId(), let userId = user?.uid else { return }
        
        if currentLoggedInUserId == userId {
            
        } else {
            DatabaseService.shared.retrieveOnce(type: .following, eventType: .value, firstChild: currentLoggedInUserId, secondChild: userId, propagate: nil, sortBy: nil, onComplete: { [weak self] (snapshot) in
                guard let this = self else { return }
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    this.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    this.setupFollowStyle()
                }
            })
            
        }
        

    }
    
    fileprivate func setupFollowStyle() {
        editProfileFollowButton.setTitle("Follow", for: .normal)
        editProfileFollowButton.backgroundColor = SignUpController.buttonActiveColor
        editProfileFollowButton.setTitleColor(.white, for: .normal)
        editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
}


// MARK: - Handlers
extension UserProfileHeader {
    func handleEditProfileOrFollow() {
        guard let uid = AuthenticationService.shared.currentId(), let userId = user?.uid else { return }
        
        if uid == userId {
            print("Edit profile happened")
            return
        }
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            DatabaseService.shared.remove(type: .following, firstChild: uid, secondChild: userId) { [weak self] (error, _) in
                if error != nil {
                    print("Error has occurred while deleting data")
                }
                self?.setupFollowStyle()
            }
        } else {
            let values = [userId: 1] as Dictionary<String, AnyObject>
            DatabaseService.shared.saveData(type: .following, data: values, firstChild: uid, secondChild: nil, appendAutoId: false) { [weak self] (error, _) in
                guard let this = self else { return }
                if error != nil {
                    print("Error has occurred while saving data")
                    return
                }
                
                this.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                this.editProfileFollowButton.backgroundColor = .white
                this.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    func handleChangeToListView() {
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    func handleChangeToGridView() {
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        gridButton.tintColor = .mainBlue()
        delegate?.didChangeToGridView()
    }
}
