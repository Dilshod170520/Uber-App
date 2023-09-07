//
//  LocationInputActivationView.swift
//  UBER
//
//  Created by MacBook Pro on 07/09/23.
//

import UIKit

class LocationInputActivationView: UIView {
    
    //MARK: - Properties
    let indecaterView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to? "
        label.font = UIFont(name: "Avenir-Light", size: 26)
        label.textColor = .darkGray
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
        
        
        
        addSubview(indecaterView)
        indecaterView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indecaterView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indecaterView.rightAnchor, paddingLeft: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
