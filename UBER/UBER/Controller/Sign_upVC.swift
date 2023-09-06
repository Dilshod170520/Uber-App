//
//  SigbUpVC.swift
//  UBER
//
//  Created by MacBook Pro on 06/09/23.
//

import UIKit

class Sign_upVC: UIViewController {
    
    //MARK: - Propertes
    
    private let titleLabe: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContener: UIView = {
        let view = UIView().inputContenerView(image: UIImage(systemName: "envelope")!, textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    
    private lazy var fullnameContener: UIView = {
        let view = UIView().inputContenerView(image: UIImage(systemName: "person")!, textField: fullnameTF)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let fullnameTF: UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    
    
    private lazy var passwordContener: UIView = {
        let view = UIView().inputContenerView(image: UIImage(systemName: "exclamationmark.lock")!, textField: passwordTF)
        view.heightAnchor.constraint(equalToConstant: 50).isActive  = true
        return view
    }()
    
    private let passwordTF: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: false)
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = UIColor(white: 1, alpha: 08)
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor(white: 1, alpha: 0.75), for: .normal)
        button.backgroundColor = UIColor.mainBlueTint
        return button
    }()
    
    private lazy var  registerType: UIView  = {
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.square.fill")
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = false
        
        view.addSubview(imageView)
        imageView.ancher(top: view.topAnchor,
                         left: view.leftAnchor,
                         paddingLeft: 8,
                         width: 24,
                         height: 24)
        
        let stack = UIStackView(arrangedSubviews: [riderButton, driverButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
    
        view.addSubview(stack)
        stack.ancher(top: imageView.bottomAnchor,
                     left: view.leftAnchor,
                     right:  view.rightAnchor,
                     paddingTop: 10,
                     paddingLeft: 8,
                     paddingRight: 8,
                     height: 40)
        
        
        let separateView = UIView()
        separateView.backgroundColor = .lightGray

        view.addSubview(separateView)
        separateView.ancher(top: stack.bottomAnchor,
                            left: view.leftAnchor,
                            right:  view.rightAnchor,
                            paddingTop: 15 ,
                            paddingLeft: 8 ,
                            paddingRight: 8,
                            height: 1)
        
       
        return view
    }()
    
    private let riderButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rider", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return button
    }()
    
    private let driverButton: UIButton = {
        let button  = UIButton()
        button.setTitle("Driver", for: .normal)
        button.backgroundColor = .yellow
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return button
    }()
    
    private let alreadyHaveAccount: UIButton = {
        let button = UIButton(type: .system)
        let attributed = NSMutableAttributedString(string: "Already have an account?    " , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.white])
        
        attributed.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.setAttributedTitle(attributed, for: .normal)
        return button
    }()
    
   
    //MARK: LiveCycle
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabe)
        titleLabe.ancher(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabe.centerX(inView: view)
        
        
        let stack = UIStackView(arrangedSubviews: [ emailContener, fullnameContener, passwordContener])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24

        view.addSubview(stack)
        stack.ancher(top: titleLabe.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 40,
                     paddingLeft: 16 ,
                     paddingRight: 16 )
        
        view.addSubview(registerType)
        registerType.ancher(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 24, paddingLeft: 16, paddingRight: 16, height: 100)
        
        view.addSubview(signupButton)
        signupButton.ancher(top: registerType.bottomAnchor,
                            left: view.leftAnchor,
                            right: view.rightAnchor,
                            paddingTop: 20,
                            paddingLeft: 16,
                            paddingRight: 16,
                            height: 50)

        
        view.addSubview(alreadyHaveAccount)
        alreadyHaveAccount.ancher( bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 5)
        alreadyHaveAccount.centerX(inView: view)
    }
}
