//
//  Extantions.swift
//  UBER
//
//  Created by MacBook Pro on 05/09/23.
//

import UIKit

extension UIView {
    
    
    func inputContenerView(image: UIImage , textField: UITextField) -> UIView {
        let view = UIView()
   
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = .white
        imageView.alpha = 0.87
        
        view.addSubview(imageView)
        imageView.centerY(inView: view)
        imageView.ancher(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
        
        view.addSubview(textField)
        textField.ancher(left: imageView.rightAnchor,
                              bottom: view.bottomAnchor,
                              right: view.rightAnchor ,
                              paddingLeft: 8 ,
                              paddingBottom: 8)
        textField.centerY(inView: view)
        
        let sepaterView = UIView()
        sepaterView.backgroundColor = .lightGray
        
        view.addSubview(sepaterView)
        sepaterView.ancher(left: view.leftAnchor,
                           bottom: view.bottomAnchor,
                           right: view.rightAnchor,
                           paddingLeft: 8 ,
                           height: 0.75)
        return view
    }
    
    func ancher(top: NSLayoutYAxisAnchor? = nil ,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0 ,
                paddingLeft: CGFloat = 0 ,
                paddingBottom: CGFloat = 0 ,
                paddingRight: CGFloat = 0 ,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView ) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    func centerY(inView view: UIView) {
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
extension UITextField {
    func textField(withPlaceholder placeholder: String , isSecureTextEntry: Bool) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .white
        textField.keyboardAppearance = .dark
        
        textField.isSecureTextEntry = isSecureTextEntry
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray ])
        return textField
    }
}
