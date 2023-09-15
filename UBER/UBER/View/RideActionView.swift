//
//  RideActionView.swift
//  UBER
//
//  Created by MacBook Pro on 15/09/23.
//

import UIKit
import MapKit

class RideActionView: UIView {

//MARK: - Properteis
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name 
            adressLabel.text = destination?.address
        }
    }
   private let titleLabel: UILabel = {
        let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 25 )
        label.text = "address test title"
        label.textAlignment = .center
        return label
    }()
    
   private let adressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Samarqand darvoza"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let uberXlabel: UILabel = {
        let label = UILabel()
        label.text = "UBER X"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFORM UBER X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.addTarget(self, action: #selector(actionBtnPressed), for: .touchUpInside)
        return button
    }()
        
//MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
         
        let stack = UIStackView(arrangedSubviews: [titleLabel, adressLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.ancher(top: topAnchor, paddingTop: 15)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.ancher(top: stack.bottomAnchor, paddingTop: 10)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(uberXlabel)
        uberXlabel.centerX(inView: self)
        uberXlabel.ancher(top: infoView.bottomAnchor, paddingTop: 15)
         
        let sepaterView = UIView()
        sepaterView.backgroundColor = .lightGray
        addSubview(sepaterView)
        sepaterView.ancher(top: uberXlabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 5, height: 0.76)
        
        addSubview(actionButton)
        actionButton.ancher( left: leftAnchor,
                             bottom: safeAreaLayoutGuide.bottomAnchor,
                             right: rightAnchor ,
                             paddingLeft: 15,
                             paddingBottom: 10,
                             paddingRight: 15,
                             height: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selecters
    @objc func actionBtnPressed() {
        
    }
}
