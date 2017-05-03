//
//  CommentsController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 5/1/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class CommentsController: UICollectionViewController, Alerter {
    
    var post: Post? {
        didSet {
            
        }
    }
    
    lazy var containerView: UIView = { [unowned self] in
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        
        containerView.addSubview(self.submitButton)
        self.submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: self.submitButton.leftAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        return containerView
    }()
    
    lazy var submitButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment"
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = .blue
        
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
}

// MARK: - Handlers
extension CommentsController {
    func handleSubmit() {
        
        guard let uid = AuthenticationService.shared.currentId() else { return }
        let postId = self.post?.id ?? ""
        let data = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: AnyObject]
        
        DatabaseService.shared.saveData(type: .comments, data: data, firstChild: postId, secondChild: nil, appendAutoId: true) { [weak self] (error, _) in
            guard let this = self else { return }
            if let error = error {
                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
            }
        }
    }
}
