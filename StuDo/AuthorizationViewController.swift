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
    }
    
    
    
    let logoImageView = UIImageView()
    let titleLabel = UILabel()
    let mottoLabel = UILabel()
    
    
    let containerView = UIView()
    let scrollView = UIScrollView()
    
    let topInnerContainerView = UIView()
    let bottomInnerContainerView = UIView()
    
    let credentialsStackView = UIStackView()
    let controlStackView = UIStackView()
    
    
    
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let checkPasswordTextField = UITextField()
    
    
    let forgotPasswordButton = UIButton()
    let proceedButtton = UIButton()
    let changeModeButton = UIButton()
    
    
    
    var containerViewHeightConstraint: NSLayoutConstraint!
    var containerViewTopConstraint: NSLayoutConstraint!
    
    var initialContainerViewHeight: CGFloat!
    
    
    
    
    static private let darkBlue = UIColor(red:0.209, green:0.409, blue:0.695, alpha:1.000)
    static private let lightBlue = UIColor(red:0.313, green:0.549, blue:0.921, alpha:1.000)
    static private let darkGreen = UIColor(red:0.219, green:0.560, blue:0.573, alpha:1.000)
    static private let lightGreen = UIColor(red:0.697, green:0.941, blue:0.568, alpha:1.000)
    static private let yellow = UIColor(red:0.971, green:0.799, blue:0.416, alpha:1.000)
    static private let orange = UIColor(red:0.987, green:0.659, blue:0.503, alpha:1.000)
    static private let pink = UIColor(red:0.952, green:0.447, blue:0.597, alpha:1.000)
    static private let violette = UIColor(red:0.664, green:0.567, blue:0.825, alpha:1.000)
    
    private let proceedColor = UIColor(red:0.000, green:0.467, blue:1.000, alpha:1.000)
    private let modeColor = UIColor(red:0.184, green:0.184, blue:0.184, alpha:1.000)
    
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
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.green.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.addSublayer(gradientLayer)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.animateGradient()
        }
        animateGradient()
        
        
        
        let logoSize: CGFloat = 180
        
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: logoSize).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: logoSize).isActive = true
        
        logoImageView.image = #imageLiteral(resourceName: "rtu-itlab-logo")
        
        
        
        
        
        let fieldHeight: CGFloat = 50
        let stackViewSpacing: CGFloat = 24
        
        let topInnerContainerInitialHeight: CGFloat = 2 * fieldHeight + 5 * stackViewSpacing
        let bottomInnerContainerInitialHeight: CGFloat = 2 * fieldHeight + 3 * stackViewSpacing
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        initialContainerViewHeight = topInnerContainerInitialHeight + bottomInnerContainerInitialHeight + statusBarHeight
        
        
        
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: initialContainerViewHeight)
        containerViewHeightConstraint.isActive = true
        
        containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor)
        containerViewTopConstraint.isActive = false
        
        containerView.backgroundColor = .init(white: 1, alpha: 0.6)
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
        
        
        
        scrollView.addSubview(topInnerContainerView)
        topInnerContainerView.translatesAutoresizingMaskIntoConstraints = false
        topInnerContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        topInnerContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        topInnerContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
        topInnerContainerView.heightAnchor.constraint(equalToConstant: topInnerContainerInitialHeight).isActive = true
        
        
        topInnerContainerView.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.topAnchor.constraint(equalTo: topInnerContainerView.topAnchor, constant: stackViewSpacing).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: topInnerContainerView.widthAnchor, multiplier: 0.8).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: topInnerContainerView.centerXAnchor).isActive = true
        
        emailTextField.borderStyle = .roundedRect
        emailTextField.textAlignment = .center
        emailTextField.placeholder = "Email"
        
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        
        
        topInnerContainerView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: stackViewSpacing).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: topInnerContainerView.centerXAnchor).isActive = true
        
        
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.textAlignment = .center
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.keyboardType = .asciiCapable
        passwordTextField.returnKeyType = .done
        
        
        
        topInnerContainerView.addSubview(forgotPasswordButton)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: stackViewSpacing / 2).isActive = true
        forgotPasswordButton.centerXAnchor.constraint(equalTo: topInnerContainerView.centerXAnchor, constant: 0).isActive = true
        
        forgotPasswordButton.setTitle("Forgot password?", for: .normal)
        forgotPasswordButton.setTitleColor(proceedColor, for: .normal)
        forgotPasswordButton.setTitleColor(proceedColor.withAlphaComponent(0.6), for: .highlighted)

        
        
        
        
        
        
        
        scrollView.addSubview(bottomInnerContainerView)
        bottomInnerContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomInnerContainerView.leadingAnchor.constraint(equalTo: topInnerContainerView.leadingAnchor).isActive = true
        bottomInnerContainerView.trailingAnchor.constraint(equalTo: topInnerContainerView.trailingAnchor).isActive = true
        bottomInnerContainerView.topAnchor.constraint(equalTo: topInnerContainerView.bottomAnchor).isActive = true
        bottomInnerContainerView.heightAnchor.constraint(equalToConstant: bottomInnerContainerInitialHeight).isActive = true
        bottomInnerContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        
        
        bottomInnerContainerView.addSubview(proceedButtton)
        proceedButtton.translatesAutoresizingMaskIntoConstraints = false
        proceedButtton.topAnchor.constraint(equalTo: bottomInnerContainerView.topAnchor, constant: stackViewSpacing).isActive = true
        proceedButtton.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        proceedButtton.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        proceedButtton.centerXAnchor.constraint(equalTo: topInnerContainerView.centerXAnchor).isActive = true
        
        proceedButtton.setTitle("Sign In", for: .normal)
        proceedButtton.setTitleColor(.white, for: .normal)
        proceedButtton.layer.borderWidth = 2
        proceedButtton.layer.cornerRadius = 8
        proceedButtton.layer.masksToBounds = true
        proceedButtton.layer.backgroundColor = proceedColor.cgColor
        proceedButtton.layer.borderColor = proceedColor.cgColor
        
        
        bottomInnerContainerView.addSubview(changeModeButton)
        changeModeButton.translatesAutoresizingMaskIntoConstraints = false
        changeModeButton.topAnchor.constraint(equalTo: proceedButtton.bottomAnchor, constant: stackViewSpacing).isActive = true
        changeModeButton.centerXAnchor.constraint(equalTo: topInnerContainerView.centerXAnchor).isActive = true
        changeModeButton.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        changeModeButton.heightAnchor.constraint(equalTo: emailTextField.heightAnchor).isActive = true
        
        changeModeButton.setTitle("Sign Up", for: .normal)
        changeModeButton.setTitleColor(modeColor, for: .normal)
        changeModeButton.layer.borderWidth = 2
        changeModeButton.layer.cornerRadius = 8
        changeModeButton.layer.borderColor = modeColor.cgColor
        
        
        
        
        
        
        
        client.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
            let freeSpace = view.frame.height - containerView.frame.height
            let offsetToFreeSpaceCenter = -freeSpace / 2 + logoImageView.frame.height / 2
            logoImageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: offsetToFreeSpaceCenter).isActive = true
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
        
        containerViewTopConstraint.isActive = toFullscreen
        
        
        containerViewHeightConstraint.constant = toFullscreen ? view.frame.height : initialContainerViewHeight
        
        containerView.setNeedsUpdateConstraints()
        scrollView.alwaysBounceVertical = toFullscreen
//        scrollView.contentInsetAdjustmentBehavior = toFullscreen ? .always : .never
        
        
        UIView.animate(withDuration: 4) {
            self.containerView.layoutIfNeeded()
            self.containerView.layer.cornerRadius = toFullscreen ? 0 : 8
            self.logoImageView.alpha = toFullscreen ? 0 : 1
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
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
    
    fileprivate func clearTextFields() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        checkPasswordTextField.text = ""
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        //        switch segmented_control.selectedSegmentIndex {
        //        case 0:
        //            firstNameTextField.isHidden = false
        //            lastNameTextField.isHidden = false
        //            checkPasswordTextField.isHidden = false
        //
        //            clearTextFields()
        //
        //            break
        //        case 1:
        //            firstNameTextField.isHidden = true
        //            lastNameTextField.isHidden = true
        //            checkPasswordTextField.isHidden = true
        //
        //            clearTextFields()
        //            break
        //        default:
        //            break
        //        }
        //
        //        self.dismissKeyboard()
    }
    
    
    @IBAction func proceedButttonTapped(_ sender: Any) {
        
        let login = emailTextField.text
        let pass = passwordTextField.text
        let pass_2 = checkPasswordTextField.text
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        
        //        switch segmented_control.selectedSegmentIndex {
        //        case 0:
        //            if login == "" || pass == "" || pass_2 == "" || firstName == "" || lastName == "" {
        //                displayMessage(userMessage: "Заполнены не все поля")
        //                return
        //            }
        //            if pass != pass_2 {
        //                displayMessage(userMessage: "Пароли не совпадают")
        //                return
        //            }
        //            let user = User(id: nil, firstName: firstName!, lastName: lastName!, email: login!, studentID: nil, password: pass!)
        //            client.register(user: user)
        //            break
        //        case 1:
        //            if login == "" || pass == "" {
        //                displayMessage(userMessage: "Заполнены не все поля")
        //                return
        //            }
        //            client.login(withCredentials: Credentials(email: login!, password: pass!))
        //            break
        //        default:
        //            break
        //        }
        
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Ooops...", message: userMessage, preferredStyle: .alert)
            let OkButton = UIAlertAction(title: "Ok", style: .default)
            {
                (action:UIAlertAction!) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            alertController.addAction(OkButton)
        }
    }
}




extension AuthorizationViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        displayMessage(userMessage: error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User) {
        
        PersistentStore.shared.user = user
        PersistentStore.save()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.tabBarController.refreshDataInsideControllers()
        }
        
        dismiss(animated: true, completion: nil)
    }
    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User) {
        client.login(withCredentials: Credentials(email: user.email, password: user.password!))
    }
}
