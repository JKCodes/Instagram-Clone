//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/4/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate, Alerter {
    
    fileprivate let signUpButtonHeight: CGFloat = 50
    fileprivate static let logoImageViewWidth: CGFloat = 200
    fileprivate static let logoImageViewHeight: CGFloat = 50
    fileprivate let logoContainerViewHeight: CGFloat = 150
    fileprivate let inputFieldPadding: CGFloat = 40
    fileprivate let inputFieldHeight: CGFloat = 140
    
    fileprivate static let buttonActiveColor: UIColor = .rgb(r: 17, g: 154, b: 237)
    fileprivate static let buttonInactiveColor: UIColor = .rgb(r: 149, g: 204, b: 244)
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: logoImageViewWidth, heightConstant: logoImageViewHeight)
        logoImageView.anchorCenterXYSuperview()
        view.backgroundColor = UIColor.rgb(r: 0, g: 120, b: 175)
        return view
    }()

    lazy var emailTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .emailAddress
        tf.addTarget(this, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.delegate = this
        return tf
    }()
    
    lazy var passwordTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(this, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.delegate = this
        return tf
    }()
    
    lazy var loginButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = LoginController.buttonInactiveColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(this, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var dontHaveAccountButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(r: 17, g: 154, b: 237)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(this, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoContainerView)

        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: logoContainerViewHeight)
        
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        view.addSubview(dontHaveAccountButton)
        
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: signUpButtonHeight)
        
        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: inputFieldPadding, leftConstant: inputFieldPadding, bottomConstant: 0, rightConstant: inputFieldPadding, widthConstant: 0, heightConstant: inputFieldHeight)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LoginController {
    
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        if email.count < 1 || password.count < 1 { return }
        
        AuthenticationService.shared.signIn(email: email, password: password) { [weak self] (error, user) in
            guard let this = self else { return }
        
            if let error = error {
                this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
                return
            }
            
            guard let customTabBarController = UIApplication.shared.keyWindow?.rootViewController as? CustomTabBarController else { return }
            
            customTabBarController.setupViewControllers()
            
            this.dismiss(animated: true, completion: nil)
        }

    }
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        loginButton.backgroundColor = isFormValid ? LoginController.buttonActiveColor : LoginController.buttonInactiveColor
        loginButton.isEnabled = isFormValid ? true : false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleLogin()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
