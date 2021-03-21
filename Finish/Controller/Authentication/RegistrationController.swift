//
//  RegistrationController.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import UIKit
import Firebase
import ProgressHUD
import SafariServices

class RegistrationController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
        
    private var profileImage: UIImage?
    
    private let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private let emailTextField = CustomTextField(placeholder: "メールアドレス")
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "パスワード（半角英数字/6文字以上）", isSecureField: true)
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let repeatPasswordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "パスワード確認", isSecureField: true)
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let fullnameTextField = CustomTextField(placeholder: "名前")
    
    private let usernameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "ユーザーネーム")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let registrationButton: CustomButton = {
        let button = CustomButton(title: "新規作成", type: .system)
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        return button
    }()
    
    private let teamsOfServiceLabel: UILabel = {
        let label = UILabel()
        label.text = "アカウントを新規作成すると、"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let teamsOfServiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("利用規約およびプライバシーポリシー", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleShowTeamsOfService), for: .touchUpInside)
        return button
    }()
    
    private let agreedLabel: UILabel = {
        let label = UILabel()
        label.text = "に同意したことになります。"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let goToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "既にアカウントをお持ちの方は", secondPart: "こちら")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureTextFieldObservers()
    }
    
    //MARK: - Selectors
    
    @objc func handleSelectPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleRegistration() {
        showLoader(true, withText: "新規作成中")
        guard let profileImage = profileImage else {
            showLoader(false)
            ProgressHUD.showError("プロフィール画像が選択されていません。")
            return
        }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let repeatPassword = repeatPasswordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        
        if password == repeatPassword {
            let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
            
            AuthService.shared.registerUser(credentials: credentials) { (error) in
                if let error = error {
                    self.showLoader(false)
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                
                self.showLoader(false)
                guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
                guard let tab = window.rootViewController as? MainTabController else { return }
                tab.authenticateUserAndConfigureUI()
                
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.showLoader(false)
            ProgressHUD.showError("パスワードが一致しません。")
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShowTeamsOfService() {
        let webPage = "https://shimurakeita.github.io/TermsOfService-COCOLOTalk-/"
        let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
        present(safariVC, animated: true, completion: nil)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == repeatPasswordTextField {
            viewModel.repeatPassword = sender.text
        } else if sender == fullnameTextField {
            viewModel.fullname = sender.text
        } else {
            viewModel.username = sender.text
        }
        
        checkForStatus()
    }
    
    @objc func keybordWillShow() {
        if view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 150
        }
    }
    
    @objc func keybordWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Helpers
    
    func checkForStatus() {
        if viewModel.formIsValid {
            registrationButton.isEnabled = true
            registrationButton.backgroundColor = UIColor(named: "buttonBackgroundColor")
            registrationButton.setTitleColor(UIColor(named: "buttonTitleColor"), for: .normal)
        } else {
            registrationButton.isEnabled = false
            registrationButton.backgroundColor = .lightGray
            registrationButton.setTitleColor(.white, for: .normal)
        }
    }
    
    func configure() {
        view.backgroundColor = UIColor(named: "loginBackgroundColor")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(selectPhotoButton)
        selectPhotoButton.setDimensions(width: 128, height: 128)
        selectPhotoButton.centerX(inView: view)
        selectPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        
        let teamsOfServiceStack = UIStackView(arrangedSubviews: [teamsOfServiceLabel, teamsOfServiceButton, agreedLabel])
        teamsOfServiceStack.axis = .vertical
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, repeatPasswordTextField, fullnameTextField, usernameTextField, teamsOfServiceStack, registrationButton])
        stack.axis = .vertical
        stack.spacing = 5
        
        view.addSubview(stack)
        stack.anchor(top: selectPhotoButton.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(goToLoginButton)
        goToLoginButton.anchor(left: view.leftAnchor,
                                      bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                      right: view.rightAnchor, paddingLeft: 32, paddingBottom: 16, paddingRight: 32)
    }
    
    func configureTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        selectPhotoButton.layer.cornerRadius = 128 / 2
        selectPhotoButton.layer.masksToBounds = true
        selectPhotoButton.imageView?.contentMode = .scaleAspectFill
        selectPhotoButton.imageView?.clipsToBounds = true
        selectPhotoButton.layer.borderColor = UIColor.white.cgColor
        selectPhotoButton.layer.borderWidth = 3
        
        self.selectPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}
