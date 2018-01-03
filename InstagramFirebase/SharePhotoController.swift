//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/5/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SharePhotoController: UIViewController, Alerter {
    
    fileprivate let contentOffset: CGFloat = 8
    fileprivate let containerViewHeight: CGFloat = 100
    
    static internal let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")

    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(r: 240, g: 240, b: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
    
        setupImageAndTextViews()
    }
    
    fileprivate func setupImageAndTextViews() {
        view.addSubview(containerView)
        containerView.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: containerViewHeight)
        
        containerView.addSubview(imageView)
        containerView.addSubview(textView)
        
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, topConstant: contentOffset, leftConstant: contentOffset, bottomConstant: contentOffset, rightConstant: contentOffset, widthConstant: containerViewHeight - contentOffset * 2, heightConstant: 0)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: contentOffset / 2, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func saveToDatabase(imageUrl: String) {
        guard let uid = AuthenticationService.shared.currentId(), let caption = textView.text, let postImage = selectedImage else { return }
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String: AnyObject]

        DatabaseService.shared.saveData(type: .post, data: values, firstChild: uid, secondChild: nil, appendAutoId: true) { [weak self] (error, _) in
            guard let this = self else { return }
            if let error = error {
                this.navigationItem.rightBarButtonItem?.isEnabled = true
                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
            }
            
            this.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension SharePhotoController {
    @objc func handleShare() {
        guard let image = selectedImage, let uploadData = UIImageJPEGRepresentation(image, 0.3), let caption = textView.text else { return }
        if caption.count < 1 {
            present(alertVC(title: "Caption is empty", message: "Please enter some text for your image"), animated: true, completion: nil)
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        StorageService.shared.uploadToStorage(type: .image, data: uploadData, url: nil) { [weak self] (error, metadata) in
            guard let this = self else { return }
            if let error = error {
                this.navigationItem.rightBarButtonItem?.isEnabled = true
                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            this.saveToDatabase(imageUrl: imageUrl)
            
        }
    }
}
