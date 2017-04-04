//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserProfileController: UICollectionViewController, Alerter {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        DatabaseService.shared.retrieveSingleObject(queryString: uid, type: .user) { [weak self] (snapshot) in
            guard let this = self else { return }
            
            let dictionary = snapshot?.value as? [String: Any]
            
            guard let username = dictionary?["username"] as? String else { return }
            
            this.navigationItem.title = username
        }
    }
}
