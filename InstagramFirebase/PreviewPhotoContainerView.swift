//
//  PreviewPhotoContainerView.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/27/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    
    fileprivate let defaultSpacing: CGFloat = 12
    fileprivate let cancelSaveButtonLength: CGFloat = 50
    fileprivate let savedLabelHeight: CGFloat = 80
    fileprivate let savedLabelWidth: CGFloat = 150

    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    lazy var cancelButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow"), for: .normal)
        button.addTarget(this, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "save_shadow"), for: .normal)
        button.addTarget(this, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    lazy var savedLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Successfully"
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0, alpha: 0.3)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.fillSuperview()
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: defaultSpacing, leftConstant: defaultSpacing, bottomConstant: 0, rightConstant: 0, widthConstant: cancelSaveButtonLength, heightConstant: cancelSaveButtonLength)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: defaultSpacing * 2, bottomConstant: defaultSpacing * 2, rightConstant: 0, widthConstant: cancelSaveButtonLength, heightConstant: cancelSaveButtonLength)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Handlers
extension PreviewPhotoContainerView {
    func handleCancel() {
        removeFromSuperview()
    }
    
    func handleSave() {
        
        guard let previewImage = previewImageView.image else { return }
        
        let library = PHPhotoLibrary.shared()
        
        library.performChanges({ 
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        }) { [weak self] (success, error) in
            if let error = error {
                print("Failed to save image to photo library:", error)
                return
            }
            
            self?.displaySavedLabel()
        }
        
    }
}

// MARK: - Others
extension PreviewPhotoContainerView {
    fileprivate func displaySavedLabel() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            this.savedLabel.frame = CGRect(x: 0, y: 0, width: this.savedLabelWidth, height: this.savedLabelHeight)
            this.savedLabel.center = this.center
            
            this.addSubview(this.savedLabel)
            
            this.savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                
                this.savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: { (_) in
                
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    this.savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    this.savedLabel.alpha = 0
                    
                }, completion: { (_) in
                    this.savedLabel.removeFromSuperview()
                })
                
            })
        }
    }
}
