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
    fileprivate let cellId = "cellId"
    fileprivate let homePostCellId = "homePostCellId"
    fileprivate let headerHeight: CGFloat = 200
    fileprivate var homeCellHeight: CGFloat = 0

    var userId: String?
    
    var user: User?
    var posts = [Post]()
    var isGridView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setupLogOutButton()
        
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        
        guard let uid = userId ?? AuthenticationService.shared.currentId() else { return }
        
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: uid, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self, let dictionary = snapshot.value as? [String: Any] else { return }
                        
            this.user = User(uid: uid, dictionary: dictionary)
            this.navigationItem.title = this.user?.username
            
            this.collectionView?.reloadData()
            
            this.fetchOrderedPosts()
        }
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = self.user?.uid else { return }

        DatabaseService.shared.retrieve(type: .post, eventType: .childAdded, firstChild: uid, secondChild: nil, propagate: nil, sortBy: "creationDate") { [weak self] (snapshot) in
            guard let this = self, let user = this.user, let dictionary = snapshot.value as? [String: Any] else { return }
                        
            let post = Post(user: user, dictionary: dictionary)

            this.posts.insert(post, at: 0)
            
            this.collectionView?.reloadData()

        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        header.user = user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: headerHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            homeCellHeight = view.frame.width // height = width
            homeCellHeight += HomePostCell.cellHeightMinusPhoto
            
            return CGSize(width: view.frame.width, height: homeCellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
}

// MARK: - Delegate: UserProfileHeaderDelegate
extension UserProfileController: UserProfileHeaderDelegate {
    func didChangeToListView() {
        if !isGridView { return }
        swapGridList()
    }
    
    func didChangeToGridView() {
        if isGridView { return }
        swapGridList()
    }
        
    fileprivate func swapGridList() {
        isGridView = !isGridView
        collectionView?.reloadData()
    }
}

// MARK: - Handlers
extension UserProfileController {
    func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            AuthenticationService.shared.signOut(onCompletion: { [weak self] (error, _) in
                guard let this = self else { return }
                
                if let error = error {
                    this.present(this.alertVC(title: "Error signing out", message: error), animated: true, completion: nil)
                    return
                }
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                this.present(navController, animated: true, completion: nil)
                
            })
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
        present(alertController, animated: true, completion: nil)
    }
}
