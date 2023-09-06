//
//  AuthButton.swift
//  UBER
//
//  Created by MacBook Pro on 06/09/23.
//

import UIKit

class AuthButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel?.font = UIFont.systemFont(ofSize: 20)
        backgroundColor = UIColor.mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
