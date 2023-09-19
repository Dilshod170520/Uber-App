//
//  LoginController.swift
//  UBER
//
//  Created by MacBook Pro on 06/09/23.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    
    private lazy var  emailContainerView: UIView = {
        let view = UIView().inputContenerView(image: UIImage(systemName: "envelope")!, textField: emailTextFeild)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextFeild: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private  lazy var passwordContainer: UIView = {
        let view = UIView().inputContenerView(image: UIImage(systemName: "exclamationmark.lock")!, textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: false)
    }()
    
    private let loginButton : AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return  button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don`t have an account?   ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.foregroundColor : UIColor.mainBlueTint]))
        button.addTarget(self, action: #selector(handlShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
   
    //MARK: - SELETERS
    
    @objc func handlShowSignUp() {
        let nav = SignUpController()
           navigationController?.pushViewController(nav, animated:  true)
    }
    
    @objc func handleLogin() {
        
        guard let email = emailTextFeild.text else { return}
        guard  let password = passwordTextField.text else { return}
        
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to log user in with error \( error.localizedDescription)")
                return
            }
            
            // /getting the all scenes
            let scenes = UIApplication.shared.connectedScenes
            //        getting windowScene from scenes
            let windowScene = scenes.first as? UIWindowScene
            //        getting window from windowScene
            let window = windowScene?.windows.first
            //        getting the root view controller
            let rootVC = window?.rootViewController as? HomeViewController
            //        changing the root view controller
             window?.rootViewController = HomeViewController()
            rootVC?.configure()
            self.dismiss(animated: true)
           
        }
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        
        configureNavigationBar()
        
        view.backgroundColor = UIColor.backgroundColor
        view.addSubview(titleLabel)
        titleLabel.ancher(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainer, loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.ancher(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40 , paddingLeft: 16 , paddingRight: 16 )
        
        view.addSubview( dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.ancher(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle  = .black
    }
}