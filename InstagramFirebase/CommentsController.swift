//
//  CommentsController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 5/1/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class CommentsController: UICollectionViewController, Alerter, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 50
    
    var post: Post? 
    
    var comments = [Comment]()
    
    lazy var containerView: UIView = { [unowned self] in
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        
        containerView.addSubview(self.submitButton)
        self.submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: self.submitButton.leftAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        containerView.addSubview(self.lineSeparatorView)
        self.lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        return containerView
    }()
    
    lazy var lineSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .rgb(r: 230, g: 230, b: 230)
        return view
    }()
    
    lazy var submitButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    lazy var commentTextField: UITextField = { [unowned self] in
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        tf.delegate = self
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        setupController()
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MRAK: - tf delegate

extension CommentsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSubmit()
        return true
    }
}

// MARK: - cv delegate

extension CommentsController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 1)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 9999)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        // Max of size of profileImage + spacing *2 && estimated height)
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: - Setups 
extension CommentsController {
    fileprivate func setupController() {
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
    }
}

// MARK: - Handlers
extension CommentsController {
    func handleSubmit() {
        guard let uid = AuthenticationService.shared.currentId(), let text = commentTextField.text else { return }
        if text.characters.count < 1 {
            present(alertVC(title: "Notice", message: "Please enter a comment first"), animated: true, completion: nil)
            return
        }
        
        let postId = self.post?.id ?? ""
        let data = ["text": text, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: AnyObject]
        
        DatabaseService.shared.saveData(type: .comments, data: data, firstChild: postId, secondChild: nil, appendAutoId: true) { [weak self] (error, _) in
            guard let this = self else { return }
            if let error = error {
                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
            }
            this.commentTextField.text = nil
        }
    }
}

// MARK: - Others {
extension CommentsController {
    
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        
        DatabaseService.shared.retrieve(type: .comments, eventType: .childAdded, firstChild: postId, secondChild: nil, propagate: nil, sortBy: nil) { [weak self] (snapshot) in
            guard let this = self, let commentDictionary = snapshot.value as? [String: Any], let uid = commentDictionary["uid"] as? String else { return }
            
            DatabaseService.shared.retrieveOnce(type: .user, eventType: .value, firstChild: uid, secondChild: nil, propagate: nil, sortBy: nil) { (snapshot) in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                
                let user = User(uid: uid, dictionary: userDictionary)
                let comment = Comment(user: user, dictionary: commentDictionary)
                this.comments.append(comment)
                this.collectionView?.reloadData()
            }
        }
    }
}
