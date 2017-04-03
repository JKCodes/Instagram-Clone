//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/3/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate let contentOffset: CGFloat = 40
    fileprivate let plusPhotoButtonLength: CGFloat = 140
    fileprivate let plusPhotoTopOffset: CGFloat = 40
    fileprivate let stackViewHeight: CGFloat = 200
    fileprivate let stackViewSpacing: CGFloat = 10
    fileprivate let textFieldHeight: CGFloat = 50
    
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Usename"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .blue
        button.backgroundColor = .rgb(r: 149, g: 204, b: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(plusPhotoButton)
        
        setupInputFields()
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: plusPhotoTopOffset, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: plusPhotoButtonLength, heightConstant: plusPhotoButtonLength)
        plusPhotoButton.anchorCenterXToSuperview()
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = stackViewSpacing
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: contentOffset / 2, leftConstant: contentOffset, bottomConstant: nil, rightConstant: contentOffset, widthConstant: 0, heightConstant: textFieldHeight)
    }

}

