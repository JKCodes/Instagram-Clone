//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserProfileController: UICollectionViewController, Alerter, UICollectionViewDelegateFlowLayout {
    
    fileprivate let headerId = "headerId"
    fileprivate let headerHeight: CGFloat = 200
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    fileprivate func fetchUser() {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        DatabaseService.shared.retrieveSingleObject(queryString: uid, type: .user) { [weak self] (snapshot) in
            guard let this = self else { return }
            
            guard let dictionary = snapshot?.value as? [String: Any] else { return }
            
            this.user = User(dictionary: dictionary)
            
            this.navigationItem.title = this.user?.username
            
            this.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        header.user = user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: headerHeight)
    }
}
