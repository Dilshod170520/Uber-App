//
//  LocationView.swift
//  UBER
//
//  Created by MacBook Pro on 07/09/23.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismissLocationInputView()
}

class LocationInputView: UIView {
//MARK: - Properties
    weak var delegate: LocationInputViewDelegate?
    
    var user: User? {
        didSet { titleLabel.text = user?.email }
    }
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self,
                         action: #selector(handleBackTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private  let titleLabel: UILabel = {
        let label = UILabel() 
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
        
    }()
    
    private let startLocationIndeketorView: UIView =  {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destanitionIndekatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startLocationTextField: UITextField = {
        let tf  = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .systemGroupedBackground
        tf.isEnabled = false
        
        let  padding = UIView()
        padding.setDimensions(height: 30, width: 10)
        tf.leftView = padding
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var destinetionLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination"
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 16 )
        
        let padding = UIView()
        padding.setDimensions(height: 30, width: 10)
        tf.leftView = padding
        tf.leftViewMode = .always
       return tf
    }()

 //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
       
        addSubview(backButton)
        backButton.ancher(top:  topAnchor,
                          left: leftAnchor,
                          paddingTop: 100,
                          paddingLeft: 12,
                          width: 24,
                          height: 24)

        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startLocationTextField)
        startLocationTextField.ancher(top: titleLabel.bottomAnchor,
                                      left: leftAnchor,
                                      right: rightAnchor,
                                      paddingTop: 15,
                                      paddingLeft: 40,
                                      paddingRight: 40,
                                      height: 35)
        
        addSubview(destinetionLocationTextField)
        destinetionLocationTextField.ancher(top: startLocationTextField.bottomAnchor,
                                            left: leftAnchor,
                                            right: rightAnchor,
                                            paddingTop: 12,
                                            paddingLeft: 40,
                                            paddingRight: 40,
                                            height: 35)
        
        addSubview(startLocationIndeketorView)
        startLocationIndeketorView.centerY(inView: startLocationTextField,
                                           leftAnchor: leftAnchor,
                                           paddingLeft: 20)
        startLocationIndeketorView.setDimensions(height: 8, width: 8)
        startLocationIndeketorView.layer.cornerRadius = 8  / 2
        
        
        addSubview(destanitionIndekatorView)
        destanitionIndekatorView.centerY(inView: destinetionLocationTextField,
                                         leftAnchor: leftAnchor ,
                                         paddingLeft: 20)
        destanitionIndekatorView.setDimensions(height: 8, width: 8 )
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndeketorView)
        linkingView.ancher(top: startLocationIndeketorView.bottomAnchor, bottom: destanitionIndekatorView.topAnchor , paddingTop: 5, paddingBottom: 5, width: 1.5)
        
    }
    // MARK: - Sellecter
  
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 }

