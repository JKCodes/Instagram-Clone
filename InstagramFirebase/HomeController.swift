//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/7/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    fileprivate var cellHeight: CGFloat = 0
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
    
        setupNavigationItems()
        
        fetchPosts()
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
    }

    fileprivate func fetchPosts() {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        
        DatabaseService.shared.retrieveOnce(queryString: uid, type: .user) { [weak self] (snapshot) in
            guard let this = self, let userDictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(dictionary: userDictionary)
        
            DatabaseService.shared.retrieveOnce(queryString: uid, type: .post, eventType: .value) { (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    let post = Post(user: user, dictionary: dictionary)
                    this.posts.append(post)
                })
                
                this.collectionView?.reloadData()
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellHeight = view.frame.width // height = width
        cellHeight += HomePostCell.cellHeightMinusPhoto
        
        return CGSize(width: view.frame.width, height: cellHeight)
    }
}
