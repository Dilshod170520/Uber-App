//
//  SigbUpVC.swift
//  UBER
//
//  Created by MacBook Pro on 06/09/23.
//

import UIKit
import Firebase
import GeoFire 

class SignUpController: UIViewController {
    
    //MARK: - Propertes
    private var location = LocationHandler.shared.locationManager.location
    
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
    
    private let signupButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var  accountTypeContainer: UIView  = {
        let view = UIView().inputContenerView(image: UIImage(systemName: "person.crop.square.fill")!, segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive  = true
        return view
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", " Driver"])
        sc.backgroundColor  = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
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
       configurUI()
    }
    
    
    //MARK: - Sellecters
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return}
        guard let password = passwordTF.text else { return}
        guard let fullname = fullnameTF.text else { return}
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
 
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to register user with error  \(error.localizedDescription)")
                return
            }
            guard let uid = result?.user.uid else { return}
            
           

            let values = ["email": email,
                          "fullname": fullname,
                           "accountType": accountTypeIndex ] as [String : Any]
            if accountTypeIndex == 1 {
            let geofire = GeoFire(firebaseRef:  REF_DRIVER_LOCATIONS)
            guard let location = self.location else { return }
                
                geofire.setLocation( location, forKey: uid) { error in
                    self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                }
            }
            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
         }
    }
    
    //MARK: - Helper functions
    func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(values) { error, ref in
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
    
    func configurUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabe)
        titleLabe.ancher(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabe.centerX(inView: view)
        
        
        let stack = UIStackView(arrangedSubviews: [ emailContener, fullnameContener, passwordContener, accountTypeContainer ,  ])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24

        view.addSubview(stack)
        stack.ancher(top: titleLabe.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 40,
                     paddingLeft: 16 ,
                     paddingRight: 16 )
        
      
        view.addSubview(signupButton)
        signupButton.ancher(top: stack.bottomAnchor,
                            left: view.leftAnchor,
                            right: view.rightAnchor,
                            paddingTop: 20,
                            paddingLeft: 16,
                            paddingRight: 16,
                            height: 50)

        
        view.addSubview(alreadyHaveAccount)
        alreadyHaveAccount.ancher( bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 5)
        alreadyHaveAccount.centerX(inView: view)
        
        alreadyHaveAccount.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
    }
    
    
    
}
