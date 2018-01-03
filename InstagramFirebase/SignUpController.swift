//
//  SignUpController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/3/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class SignUpController: UIViewController, UITextFieldDelegate, Alerter, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    fileprivate let contentOffset: CGFloat = 40
    fileprivate let plusPhotoButtonLength: CGFloat = 140
    fileprivate let plusPhotoTopOffset: CGFloat = 40
    fileprivate let stackViewHeight: CGFloat = 200
    fileprivate let stackViewSpacing: CGFloat = 10
    fileprivate let alreadyHaveAccountButtonHeight: CGFloat = 50
    
    internal static let buttonActiveColor: UIColor = .rgb(r: 17, g: 154, b: 237)
    fileprivate static let buttonInactiveColor: UIColor = .rgb(r: 149, g: 204, b: 244)
    
    lazy var plusPhotoButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(this, action: #selector(handlePlusPhoto), for: .touchUpInside)
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
        tf.delegate = this
        return tf
    }()
    
    lazy var usernameTextField: UITextField = { [weak self] in
        guard let this = self else { return UITextField() }
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.addTarget(this, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.delegate = this
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
        tf.delegate = this
        return tf
    }()
    
    lazy var signUpButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = SignUpController.buttonInactiveColor
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    
    lazy var alreadyHaveAccountButton: UIButton = { [weak self] in
        guard let this = self else { return UIButton() }
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(r: 17, g: 154, b: 237)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(this, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: alreadyHaveAccountButtonHeight)
        
        view.backgroundColor = .white
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }

}

extension SignUpController {
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text else { return }
        if email.count < 1 || username.count < 1 || password.count < 1 { return }
        
        AuthenticationService.shared.createUser(email: email, password: password) { [weak self] (error, user) in
            guard let this = self else { return }
            
            if let error = error {
                this.present(this.alertVC(title: "An error has occurred", message: error), animated: true, completion: nil)
                return
            }
            
            DatabaseService.shared.isUsernameUnique(username: username) { [weak self] (flag) in
                guard let this = self else { return }
                
                if !flag {
                    this.present(this.alertVC(title: "Duplicate username", message: "The chosen username has already been taken.  Please choose a different username"), animated: true, completion: nil)
                    AuthenticationService.shared.deleteCurrentUser { return }
                    return
                }
            
                guard let image = this.plusPhotoButton.imageView?.image, let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
                
                StorageService.shared.uploadToStorage(type: .profile, data: uploadData, url: nil, onComplete: { (error, metadata) in
                    if let error = error {
                        this.present(this.alertVC(title: "Error saving to storage", message: error), animated: true, completion: nil)
                        return
                    }
                    
                    guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                    
                    guard let uid = user?.uid else { return }
                    
                    
                    var dictionaryValues = ["username": username as AnyObject, "profileImageUrl": profileImageUrl as AnyObject]
                    
                    DatabaseService.shared.saveData(type: .user, data: dictionaryValues, firstChild: uid, secondChild: nil, appendAutoId: false, onComplete: { [weak self] (error, _) in
                        if let error = error {
                            this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
                            return
                        }
                        
                        
                        dictionaryValues = [username: 1 as AnyObject]
                        
                        DatabaseService.shared.saveData(type: .username, data: dictionaryValues, firstChild: nil, secondChild: nil, appendAutoId: false, onComplete: { [weak self] (error, _) in
                            guard let this = self else { return }
                            
                            if let error = error {
                                this.present(this.alertVC(title: "Error saving data", message: error), animated: true, completion: nil)
                                return
                            }
                            
                            guard let customTabBarController = UIApplication.shared.keyWindow?.rootViewController as? CustomTabBarController else { return }
                            
                            customTabBarController.setupViewControllers()
                            
                            this.dismiss(animated: true, completion: nil)
                        })
                        
                    })
                })
        
            }
        }
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        signUpButton.backgroundColor = isFormValid ? .mainBlue() : SignUpController.buttonInactiveColor
        signUpButton.isEnabled = isFormValid ? true : false
    }
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSignUp()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
