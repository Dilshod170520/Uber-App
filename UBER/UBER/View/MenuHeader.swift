//
//  MenuHeader.swift
//  UBER
//
//  Created by MacBook Pro on 19/09/23.
//

import UIKit
class MenuHeader: UIView {
    //MARK: - Properties
    
//    var user: User? {
//        didSet{
//            fullnameLabel.text = user?.fullname
//            emailLabel.text = user?.email
//        }
//    }
    private let user: User
    
    private let profileImage: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private lazy var  fullnameLabel: UILabel = {
        let l  = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = .white
        l.text = "Dilshod Qulmirzayev"
        l.text = user.fullname
        return l
    }()
    
    private lazy var emailLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Dilshod@gmail.com "
        label.text = user.email
        return label
    }()
     
    //MARK: - Lifecycle
     init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        
        addSubview(profileImage)
        profileImage.ancher(top: topAnchor,
                            left: leftAnchor,
                            paddingTop: 64, paddingLeft: 64,
                            width: 64,
                            height: 64 )
        profileImage.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(inView: profileImage, leftAnchor: profileImage.rightAnchor, paddingLeft: 12)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Sellectors
    
    //MARK:  - Helper Functions

}

