//
//  AuthorizationViewController.swift
//  StuDo
//
//  Created by Вячеслав Клевлеев on 15/06/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    var client = APIClient()
    
    
    var isInitialSetup = true
    var isFullscreen = false
    var currentMode: AuthorizationVCMode = .signIn
    enum AuthorizationVCMode {
        case signIn
        case signUp
        case resetPassword
    }
    
    
    
    let logoImageView = UIImageView()
    let titleLabel = UILabel()
    let mottoLabel = UILabel()
    
    
    let containerView = UIView()
    let scrollView = UIScrollView()
    
    let credentialsContainerView = UIView()
    let additionalInfoContainerView = UIView()
    let buttonsContainerView = UIView()
    
    
    
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let checkPasswordTextField = UITextField()
    
    
    let forgotPasswordButton = UIButton()
    let proceedButtton = UIButton()
    let changeModeButton = UIButton()
    
    
    
    var containerViewHeightConstraint: NSLayoutConstraint!
    var credentialsContainerHeightConstraint: NSLayoutConstraint!
    var additionalInfoContainerHeightConstraint: NSLayoutConstraint!
    
    var initialContainerViewHeight: CGFloat!
    var credentialsContainerFullHeight: CGFloat!
    var credentialsContainerShrunkHeight: CGFloat!
    var additionalInfoContainerFullHeight: CGFloat!
    
    
    
    static private let darkBlue = UIColor(red:0.209, green:0.409, blue:0.695, alpha:1.000)
    static private let lightBlue = UIColor(red:0.313, green:0.549, blue:0.921, alpha:1.000)
    static private let darkGreen = UIColor(red:0.219, green:0.560, blue:0.573, alpha:1.000)
    static private let lightGreen = UIColor(red:0.697, green:0.941, blue:0.568, alpha:1.000)
    static private let yellow = UIColor(red:0.971, green:0.799, blue:0.416, alpha:1.000)
    static private let orange = UIColor(red:0.987, green:0.659, blue:0.503, alpha:1.000)
    static private let pink = UIColor(red:0.952, green:0.447, blue:0.597, alpha:1.000)
    static private let violette = UIColor(red:0.664, green:0.567, blue:0.825, alpha:1.000)
    
    private lazy var proceedColor: UIColor = {
        if #available(iOS 13, *) {
            return .systemBlue
        } else {
            return UIColor(red:0.000, green:0.467, blue:1.000, alpha:1.000)
        }
    }()
    private lazy var modeColor: UIColor = {
        if #available(iOS 13, *) {
            return .secondaryLabel
        } else {
            return UIColor(red:0.184, green:0.184, blue:0.184, alpha:1.000)
        }
    }()
    
    private var currentSet = 0
    
    func nextColorSet() -> [CGColor] {
        if currentSet < colorSets.count - 1 {
            currentSet += 1
        } else {
            currentSet = 0
        }
        return colorSets[currentSet]
    }
    
    let colorSets: [[CGColor]] = [
        [darkBlue.cgColor, lightBlue.cgColor],
        [lightBlue.cgColor, darkGreen.cgColor],
        [darkGreen.cgColor, lightGreen.cgColor],
        [lightGreen.cgColor, yellow.cgColor],
        [yellow.cgColor, orange.cgColor],
        [orange.cgColor, pink.cgColor],
        [pink.cgColor, violette.cgColor],
        [violette.cgColor, darkBlue.cgColor]
    ]
    
    private let gradientLayer = CAGradientLayer()
    
    func animateGradient() {
        let colorChange = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        colorChange.duration = 2
        colorChange.fromValue = colorSets[currentSet]
        let nextSet = nextColorSet()
        colorChange.toValue = nextSet
        
        gradientLayer.colors = nextSet
        gradientLayer.add(colorChange, forKey: #keyPath(CAGradientLayer.colors))
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientLayer.colors = colorSets[currentSet]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.addSublayer(gradientLayer)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.animateGradient()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animateGradient()
        }
    
        
        
        let logoSize: CGFloat = 180
        
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: logoSize).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: logoSize).isActive = true
        
        logoImageView.image = #imageLiteral(resourceName: "rtu-itlab-logo")
        
        
        
        
        
        let fieldHeight: CGFloat = 44
        let stackViewSpacing: CGFloat = 24
        
        credentialsContainerFullHeight = 2 * fieldHeight + 5 * stackViewSpacing
        credentialsContainerShrunkHeight = 2 * fieldHeight + 2 * stackViewSpacing
        additionalInfoContainerFullHeight = 3 * fieldHeight + 5 * stackViewSpacing
        let buttonsContainerInitialHeight: CGFloat = 2 * fieldHeight + 3 * stackViewSpacing
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        initialContainerViewHeight = credentialsContainerFullHeight + buttonsContainerInitialHeight + statusBarHeight
        
        
        
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: initialContainerViewHeight)
        containerViewHeightConstraint.isActive = true
        
        if #available(iOS 13, *) {
            containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        } else {
            containerView.backgroundColor = .init(white: 1, alpha: 0.6)
        }
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = false
        
        
        
        
        let scrollViewPadding: CGFloat = 0
        
        containerView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: scrollViewPadding).isActive = true
        scrollView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: scrollViewPadding).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -scrollViewPadding).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -scrollViewPadding).isActive = true
        
        
        
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.keyboardDismissMode = .interactive
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        
        
        scrollView.addSubview(credentialsContainerView)
        credentialsContainerView.translatesAutoresizingMaskIntoConstraints = false
        credentialsContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        credentialsContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        credentialsContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        
        credentialsContainerHeightConstraint = credentialsContainerView.heightAnchor.constraint(equalToConstant: credentialsContainerFullHeight)
        credentialsContainerHeightConstraint.isActive = true
        
        
        credentialsContainerView.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.topAnchor.constraint(equalTo: credentialsContainerView.topAnchor, constant: stackViewSpacing).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: credentialsContainerView.widthAnchor, multiplier: 0.8).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: credentialsContainerView.centerXAnchor).isActive = true
        
        emailTextField.borderStyle = .roundedRect
        emailTextField.textAlignment = .center
        emailTextField.placeholder = Localizer.string(for: .authEmail)
        
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.autocapitalizationType = .none
        
        
        credentialsContainerView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: stackViewSpacing).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: credentialsContainerView.centerXAnchor).isActive = true
        
        
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.textAlignment = .center
        passwordTextField.placeholder = Localizer.string(for: .authPassword)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password

        passwordTextField.autocorrectionType = .no
        passwordTextField.keyboardType = .asciiCapable
        passwordTextField.returnKeyType = .done
        
        
        
        credentialsContainerView.addSubview(forgotPasswordButton)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: stackViewSpacing / 2).isActive = true
        forgotPasswordButton.centerXAnchor.constraint(equalTo: credentialsContainerView.centerXAnchor, constant: 0).isActive = true
        
        forgotPasswordButton.setTitle(Localizer.string(for: .authForgotPassword), for: .normal)
        forgotPasswordButton.setTitleColor(proceedColor, for: .normal)
        forgotPasswordButton.setTitleColor(proceedColor.withAlphaComponent(0.6), for: .highlighted)

        
        
        
        
        
        
        
        scrollView.addSubview(additionalInfoContainerView)
        additionalInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoContainerView.leadingAnchor.constraint(equalTo: credentialsContainerView.leadingAnchor).isActive = true
        additionalInfoContainerView.trailingAnchor.constraint(equalTo: credentialsContainerView.trailingAnchor).isActive = true
        additionalInfoContainerView.topAnchor.constraint(equalTo: credentialsContainerView.bottomAnchor).isActive = true
        
        additionalInfoContainerHeightConstraint = additionalInfoContainerView.heightAnchor.constraint(equalToConstant: 0)
        additionalInfoContainerHeightConstraint.isActive = true
        
        additionalInfoContainerView.alpha = 0
        
        
        additionalInfoContainerView.addSubview(checkPasswordTextField)
        checkPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        checkPasswordTextField.topAnchor.constraint(equalTo: additionalInfoContainerView.topAnchor, constant: stackViewSpacing).isActive = true
        checkPasswordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        checkPasswordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        checkPasswordTextField.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor).isActive = true
        
        checkPasswordTextField.borderStyle = .roundedRect
        checkPasswordTextField.textAlignment = .center
        checkPasswordTextField.placeholder = Localizer.string(for: .authRepeatPassword)
        checkPasswordTextField.isSecureTextEntry = true
        checkPasswordTextField.textContentType = .password
        
        checkPasswordTextField.autocorrectionType = .no
        checkPasswordTextField.keyboardType = .asciiCapable
        checkPasswordTextField.returnKeyType = .next
        
        
        
        additionalInfoContainerView.addSubview(firstNameTextField)
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        firstNameTextField.topAnchor.constraint(equalTo: checkPasswordTextField.bottomAnchor, constant: 2 * stackViewSpacing).isActive = true
        firstNameTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        firstNameTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        firstNameTextField.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor).isActive = true
        
        firstNameTextField.borderStyle = .roundedRect
        firstNameTextField.textAlignment = .center
        firstNameTextField.placeholder = Localizer.string(for: .authName)
        
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.returnKeyType = .next
        
        
        
        additionalInfoContainerView.addSubview(lastNameTextField)
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: stackViewSpacing).isActive = true
        lastNameTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        lastNameTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        lastNameTextField.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor).isActive = true
        
        lastNameTextField.borderStyle = .roundedRect
        lastNameTextField.textAlignment = .center
        lastNameTextField.placeholder = Localizer.string(for: .authSurname)
        
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.returnKeyType = .done
        
        
        
        
        
        
        scrollView.addSubview(buttonsContainerView)
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.leadingAnchor.constraint(equalTo: credentialsContainerView.leadingAnchor).isActive = true
        buttonsContainerView.trailingAnchor.constraint(equalTo: credentialsContainerView.trailingAnchor).isActive = true
        buttonsContainerView.topAnchor.constraint(equalTo: additionalInfoContainerView.bottomAnchor).isActive = true
        buttonsContainerView.heightAnchor.constraint(equalToConstant: buttonsContainerInitialHeight).isActive = true
        buttonsContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        
        
        buttonsContainerView.addSubview(proceedButtton)
        proceedButtton.translatesAutoresizingMaskIntoConstraints = false
        proceedButtton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor, constant: stackViewSpacing).isActive = true
        proceedButtton.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        proceedButtton.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        proceedButtton.centerXAnchor.constraint(equalTo: credentialsContainerView.centerXAnchor).isActive = true
        
        proceedButtton.setTitle(Localizer.string(for: .authSignIn), for: .normal)
        proceedButtton.setTitleColor(.white, for: .normal)
        proceedButtton.layer.borderWidth = 2
        proceedButtton.layer.cornerRadius = 8
        proceedButtton.layer.masksToBounds = true
        proceedButtton.layer.backgroundColor = proceedColor.cgColor
        proceedButtton.layer.borderColor = proceedColor.cgColor
        
        
        buttonsContainerView.addSubview(changeModeButton)
        changeModeButton.translatesAutoresizingMaskIntoConstraints = false
        changeModeButton.topAnchor.constraint(equalTo: proceedButtton.bottomAnchor, constant: stackViewSpacing).isActive = true
        changeModeButton.centerXAnchor.constraint(equalTo: credentialsContainerView.centerXAnchor).isActive = true
        changeModeButton.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        changeModeButton.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        
        changeModeButton.setTitle(Localizer.string(for: .authSignUp), for: .normal)
        changeModeButton.setTitleColor(modeColor, for: .normal)
        changeModeButton.layer.borderWidth = 2
        changeModeButton.layer.cornerRadius = 8
        changeModeButton.layer.borderColor = modeColor.cgColor
        
        
        
        client.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        proceedButtton.addTarget(self, action: #selector(proceedButttonTapped(_:)), for: .touchUpInside)
        changeModeButton.addTarget(self, action: #selector(changeModeButtonTapped(_:)), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped(_:)), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        checkPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        _ = checkIfShouldProceed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        adaptColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let scaleFactor: CGFloat = 0.9
        let logoSizeAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        logoSizeAnimation.fromValue = CATransform3DIdentity
        logoSizeAnimation.toValue = CATransform3DMakeScale(scaleFactor, scaleFactor, scaleFactor)
        logoSizeAnimation.duration = 2
        logoSizeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        logoSizeAnimation.repeatCount = Float.infinity
        logoSizeAnimation.autoreverses = true
        
        logoImageView.layer.add(logoSizeAnimation, forKey: #keyPath(CALayer.transform))
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialSetup {
            isInitialSetup = false
            
            let freeSpace = view.frame.height - containerView.frame.height
            let offsetToFreeSpaceCenter = -freeSpace / 2 + logoImageView.frame.height / 2
            logoImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: offsetToFreeSpaceCenter).isActive = true
        }
    }
    
    
    func adaptColors() {
        if #available(iOS 13, *) {
            var preferredColor: UIColor!
            if traitCollection.userInterfaceStyle == .dark {
                preferredColor = UIColor.systemBackground.withAlphaComponent(0.4)
            } else {
                preferredColor = nil
            }
            
            emailTextField.backgroundColor = preferredColor
            passwordTextField.backgroundColor = preferredColor
            checkPasswordTextField.backgroundColor = preferredColor
            firstNameTextField.backgroundColor = preferredColor
            lastNameTextField.backgroundColor = preferredColor
        }
    }
    
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if !isFullscreen {
            return .lightContent
        }
        return .default
    }
    
    
    fileprivate func animateContentContainer(toFullscreen: Bool ) {
        self.isFullscreen = toFullscreen
        
        
        containerViewHeightConstraint.constant = toFullscreen ? view.frame.height : initialContainerViewHeight
        
        containerView.setNeedsUpdateConstraints()
        scrollView.alwaysBounceVertical = toFullscreen
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.containerView.layer.cornerRadius = toFullscreen ? 0 : 8
            self.logoImageView.alpha = toFullscreen ? 0 : 1
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
    }
    
    fileprivate func animateShake(forTextField textField: UITextField) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 30, -30, 30, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 1
        textField.layer.add(animation, forKey: "shake")
    }
    
    fileprivate func animateBorder(forTextField textField: UITextField) {
        
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.init(white: 1, alpha: 0).cgColor
        
        let colorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        colorAnimation.fromValue = UIColor.red.cgColor
        colorAnimation.toValue = UIColor.init(white: 1, alpha: 0).cgColor
        colorAnimation.duration = 1
        textField.layer.add(colorAnimation, forKey: #keyPath(CALayer.borderColor))
        
        let widthAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderWidth))
        widthAnimation.fromValue = 1.8
        widthAnimation.toValue = 0
        widthAnimation.duration = 1.4
        textField.layer.add(widthAnimation, forKey: #keyPath(CALayer.borderWidth))
        
        
    }
    
    
    
    
    
    fileprivate func isEmailValid(email: String) -> Bool {
        return DataChecker.shared.isEmailValid(email)
    }
    
    fileprivate func isPasswordValid(password: String) -> Bool {
        return DataChecker.shared.isPasswordValid(password)
    }
    
    
    func checkIfShouldProceed() -> Bool {
        var shouldProceed = true
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if !isEmailValid(email: email) {
            shouldProceed = false
        }
        
        if !isPasswordValid(password: password) {
            shouldProceed = false
        }
        
        if currentMode == .signUp {
            let checkPassword = checkPasswordTextField.text!
            let name = firstNameTextField.text!
            let surname = lastNameTextField.text!
            
            if checkPassword.isEmpty || checkPassword != password {
                shouldProceed = false
            }
            
            if name.isEmpty {
                shouldProceed = false
            }
            
            if surname.isEmpty {
                shouldProceed = false
            }
        }
        
        
        UIView.animate(withDuration: 0.4, animations: {
            self.proceedButtton.alpha = shouldProceed ? 1 : 0.6
        }) { _ in
            self.proceedButtton.isEnabled = shouldProceed
        }
        
        
        return shouldProceed
        
    }
    
    
    func proceed() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let name = firstNameTextField.text!
        let surname = lastNameTextField.text!
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        checkPasswordTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        
        if currentMode == .signIn {
            let credentials = Credentials(email: email, password: password)
            client.login(withCredentials: credentials)
        } else if currentMode == .signUp {
            let newUser = User(id: nil, firstName: name, lastName: surname, email: email, studentID: nil, password: password)
            client.register(user: newUser)
        }
        
        RootViewController.startLoadingIndicator()

    }
    
    
    func changeMode() {
        currentMode = (currentMode == .signIn) ? .signUp : .signIn
        
        let proceedInFullscreen = true
        var forgotPasswordButtonAlpha: CGFloat = 1
        var additionalInfoContentsAlpha: CGFloat = 0
        
        var proceedButtonTitle = Localizer.string(for: .authSignIn)
        var changeModeButtonTitle = Localizer.string(for: .authSignUp)
        
        if currentMode == .signIn {
            additionalInfoContainerHeightConstraint.constant = 0
            credentialsContainerHeightConstraint.constant = credentialsContainerFullHeight
            
            emailTextField.becomeFirstResponder()
            
            passwordTextField.returnKeyType = .done
        } else if currentMode == .signUp {
            additionalInfoContainerHeightConstraint.constant = additionalInfoContainerFullHeight
            credentialsContainerHeightConstraint.constant = credentialsContainerShrunkHeight
            
            forgotPasswordButtonAlpha = 0
            additionalInfoContentsAlpha = 1
            
            if let email = emailTextField.text, email.isEmpty {
                emailTextField.becomeFirstResponder()
            }
            
            checkPasswordTextField.text = ""
            firstNameTextField.text = ""
            lastNameTextField.text = ""
            
            proceedButtonTitle = Localizer.string(for: .authSignUp)
            changeModeButtonTitle = Localizer.string(for: .authSignIn)
            
            passwordTextField.returnKeyType = .next
        }
        
        animateContentContainer(toFullscreen: proceedInFullscreen)
        UIView.animate(withDuration: 0.6, animations: {
            self.additionalInfoContainerView.alpha = additionalInfoContentsAlpha
            self.forgotPasswordButton.alpha = forgotPasswordButtonAlpha
        }, completion: { _ in
            self.proceedButtton.setTitle(proceedButtonTitle, for: .normal)
            self.changeModeButton.setTitle(changeModeButtonTitle, for: .normal)
        })
    }
    
    
    
    
    
    
    func displayMessage(userMessage:String, title: String? = nil) -> Void {
        let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
        
        let OkButton = UIAlertAction(title: Localizer.string(for: .okay), style: .cancel, handler: nil)
        alertController.addAction(OkButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}





extension AuthorizationViewController {
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            if currentMode == .signIn {
                animateContentContainer(toFullscreen: true)
            }
        }
    }
    
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        
        if currentMode == .signIn {
            animateContentContainer(toFullscreen: false)
        }
    }
    
    
    
    
    @IBAction func proceedButttonTapped(_ button: UIButton) {
        proceed()
    }
    
    
    
    
    @objc func changeModeButtonTapped(_ button: UIButton) {
        changeMode()
    }
    
    
    
    @objc func forgotPasswordButtonTapped(_ button: UIButton) {
        let email = emailTextField.text!
        if isEmailValid(email: email) {
            client.requestPasswordRest(forEmail: email)
            RootViewController.startLoadingIndicator()
        } else {
            animateBorder(forTextField: emailTextField)
        }
        
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        _ = checkIfShouldProceed()
    }
    
    
    
}






extension AuthorizationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField === passwordTextField {
            if currentMode == .signUp {
                checkPasswordTextField.becomeFirstResponder()
            } else {
                if checkIfShouldProceed() {
                    proceed()
                }
            }
        } else if textField === checkPasswordTextField {
            firstNameTextField.becomeFirstResponder()
        } else if textField === firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField === lastNameTextField {
            if checkIfShouldProceed() {
                proceed()
            }
        }
        
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === passwordTextField || textField === checkPasswordTextField {
            textField.text = ""
        }
    }
}






extension AuthorizationViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        RootViewController.stopLoadingIndicator(with: .fail) {
            self.displayMessage(userMessage: error.localizedDescription)
        }
    }
    
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User) {
        
        PersistentStore.shared.user = user
        
        RootViewController.stopLoadingIndicator(with: .success) {
            RootViewController.main.login()
        }
        
    }
    
    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User) {
        RootViewController.stopLoadingIndicator(with: .success) {
            self.displayMessage(userMessage: Localizer.string(for: .authRegistrationAlertMessage), title: Localizer.string(for: .authRegistrationAlertTitle))
        }
    }
    
    func apiClient(_ client: APIClient, didSentPasswordResetRequest: APIRequest) {
        RootViewController.stopLoadingIndicator(with: .success) {
            self.displayMessage(userMessage: Localizer.string(for: .authPasswordRestorationAlertMessage))
        }
    }
    
}
