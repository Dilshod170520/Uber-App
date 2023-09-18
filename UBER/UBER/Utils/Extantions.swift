//
//  Extantions.swift
//  UBER
//
//  Created by MacBook Pro on 05/09/23.
//

import UIKit
import MapKit

extension UIColor {
    static func rgb(red: CGFloat,
                    green: CGFloat,
                    blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255,
                            green: green/255,
                            blue: blue/255,
                            alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 157, blue: 237)
}
extension UIView {
    func inputContenerView(image: UIImage , textField: UITextField? = nil, segmentedControl: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = .white
        imageView.alpha = 0.87
        
        view.addSubview(imageView)
        
        if let textField = textField {
            
            imageView.centerY(inView: view)
            imageView.ancher(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(textField)
            textField.ancher(left: imageView.rightAnchor,
                             bottom: view.bottomAnchor,
                             right: view.rightAnchor ,
                             paddingLeft: 8 ,
                             paddingBottom: 8)
            textField.centerY(inView: view)
        }
        
        if let sc = segmentedControl {
            imageView.ancher(top: view.topAnchor, left: view.leftAnchor,paddingTop: -8,  paddingLeft: 8,  width: 24, height: 24)
            
            view.addSubview(sc)
            sc.ancher(top: imageView.bottomAnchor,  left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8,  paddingLeft: 8,  paddingRight: 8)
            sc.centerY(inView: view, constant: 5)
            
        }
        
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
        translatesAutoresizingMaskIntoConstraints = false 
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    func centerY(inView view: UIView ,
                 leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0 ,
                 constant: CGFloat  = 0 ) {
         translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                 constant: constant ).isActive = true
        if let left = leftAnchor {
            ancher(left: left , paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat , width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
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

extension  MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare  else { return nil}
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil}
            guard let administrativeArea = administrativeArea else { return nil}
            
            return "\(subThoroughfare) \( thoroughfare), \(locality), \( administrativeArea)"
        }
    }
    
}
//MARK: - MKMapView
extension MKMapView {
    func zoomToFit(annotation: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotation.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x,
                                      y: annotationPoint.y,
                                      width: 0.01,
                                      height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 50,
                                  left: 75,
                                  bottom: 300 ,
                                  right: 75)
        setVisibleMapRect(zoomRect,
                          edgePadding: insets,
                          animated: true )
    }
}
extension UIViewController {
    func presentAlertController(withTitle title: String ,  messege: String) {
        let alert = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
    func shouldPresentLocationView(_ present: Bool, massege: String? = nil) {
        if present {
            let loudingView = UIView()
            loudingView.frame = self.view.frame
            loudingView.backgroundColor = .black
            loudingView.alpha = 0
            loudingView.tag = 1
             
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.center = view.center
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 24)
            label.text = massege
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87 
            
            view.addSubview(loudingView)
            loudingView.addSubview(indicator)
            loudingView .addSubview(label)
            
            label.centerX(inView: view)
            label.ancher(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loudingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}

