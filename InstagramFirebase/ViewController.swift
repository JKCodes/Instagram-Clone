//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/3/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, Alerter {

    fileprivate let contentOffset: CGFloat = 40
    fileprivate let plusPhotoButtonLength: CGFloat = 140
    fileprivate let plusPhotoTopOffset: CGFloat = 40
    fileprivate let stackViewHeight: CGFloat = 200
    fileprivate let stackViewSpacing: CGFloat = 10
    
    fileprivate static let buttonActiveColor: UIColor = .rgb(r: 17, g: 154, b: 237)
    fileprivate static let buttonInactiveColor: UIColor = .rgb(r: 149, g: 204, b: 244)
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    lazy var emailTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.keyboardType = .emailAddress
        tf.addTarget(this, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var usernameTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Usename"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.addTarget(this, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var passwordTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(this, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var signUpButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = buttonInactiveColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
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
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: contentOffset / 2, leftConstant: contentOffset, bottomConstant: 0, rightConstant: contentOffset, widthConstant: 0, heightConstant: stackViewHeight)
    
    }

}

extension ViewController {
    func handleSignUp() {
        
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text else { return }
        if email.characters.count < 1 || username.characters.count < 1 || password.characters.count < 1 { return }
        
        AuthenticationService.shared.createUser(email: email, password: password) { [weak self] (error, user) in
            guard let this = self else { return }
            if let error = error {
                this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
            }
            
            
        }
    }
    
    func handleTextInputChange() {
        let isFormValid = emailTextField.text?.characters.count ?? 0 > 0 && usernameTextField.text?.characters.count ?? 0 > 0 && passwordTextField.text?.characters.count ?? 0 > 0
        signUpButton.backgroundColor = isFormValid ? ViewController.buttonActiveColor : ViewController.buttonInactiveColor
        signUpButton.isEnabled = isFormValid ? true : false
    }
}
