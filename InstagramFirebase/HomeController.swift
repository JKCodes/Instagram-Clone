//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/7/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate, Alerter {
    
    fileprivate let cellId = "cellId"
    fileprivate var cellHeight: CGFloat = 0
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = .white
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
    
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        
        fetchPosts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    fileprivate func fetchPosts() {
        guard let uid = AuthenticationService.shared.currentId() else { return }
        fetchPost(id: uid)
        
        DatabaseService.shared.retrieveOnce(type: .following, eventType: .value, firstChild: uid, secondChild: nil, propagate: false, sortBy: nil) { [weak self] (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: AnyObject] else { return }
            
            userIdsDictionary.forEach({ [weak self] (key, value) in
                self?.fetchPost(id: key)
            })
            
        }
    }
    
    fileprivate func fetchPost(id: String) {
        
        DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: id, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self, let userDictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: id, dictionary: userDictionary)
            
            this.fetchPostWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostWithUser(user: User) {
        
        DatabaseService.shared.retrieveOnce(type: .post, eventType: .value, firstChild: user.uid, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self, let dictionaries = snapshot.value as? [String: Any] else { return }
            
            this.collectionView?.refreshControl?.endRefreshing()
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any], let uid = AuthenticationService.shared.currentId() else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                DatabaseService.shared.retrieveOnce(type: .like, eventType: .value, firstChild: key, secondChild: uid, propagate: false, sortBy: nil, onComplete: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    this.posts.append(post)
                    this.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    
                    this.collectionView?.reloadData()
                })
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        cell.delegate = self
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellHeight = view.frame.width // height = width
        cellHeight += HomePostCell.cellHeightMinusPhoto
        
        return CGSize(width: view.frame.width, height: cellHeight)
    }
}


// MARK: - Handlers
extension HomeController {
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
}

// MARK: - Delegation
extension HomeController {
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell), let uid = AuthenticationService.shared.currentId() else { return }
        
        var post = posts[indexPath.item]
        
        guard let postId = post.id else { return }
        
        let values = [uid: post.hasLiked == true ? 0 : 1] as [String: AnyObject]
        DatabaseService.shared.saveData(type: .like, data: values, firstChild: postId, secondChild: nil, appendAutoId: false) { [weak self] (error, _) in
            guard let this = self else { return }
            if error != nil {
                this.present(this.alertVC(title: "Error saving data", message: "An expected error has occured while liking a post.  Please try again"), animated: true, completion: nil)
                return
            }
            
            post.hasLiked = !post.hasLiked
            this.posts[indexPath.item] = post
            this.collectionView?.reloadItems(at: [indexPath])
        }
        
    }
}
