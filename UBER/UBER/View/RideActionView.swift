//
//  RideActionView.swift
//  UBER
//
//  Created by MacBook Pro on 15/09/23.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploudTrip(_ view: RideActionView)
    func cencelTrip()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassanger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomStringConvertible {
    case requesRide
    case cencel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requesRide : return "REQUST RIDE"
        case .cencel: return "CENCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROP OFF PASSENGER"
        }
    }
    init() {
        self = .requesRide
    }
}

class RideActionView: UIView {

//MARK: - Properteis
    weak var delegate: RideActionViewDelegate?
    
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()
    var user: User? 
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name 
            adressLabel.text = destination?.address
        }
    }
   private let titleLabel: UILabel = {
        let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 25 )
        label.textAlignment = .center
        return label
    }()
    
   private let adressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel .centerY(inView: view)
        
        return view
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.text = "X"
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        return label
    }()
    
    private let uberInfolabel: UILabel = {
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
        
        addSubview(uberInfolabel)
        uberInfolabel.centerX(inView: self)
        uberInfolabel.ancher(top: infoView.bottomAnchor, paddingTop: 15)
         
        let sepaterView = UIView()
        sepaterView.backgroundColor = .lightGray
        addSubview(sepaterView)
        sepaterView.ancher(top: uberInfolabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 5, height: 0.76)
        
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
        switch buttonAction {
        case .requesRide:
            delegate?.uploudTrip(self)
        case .cencel:
            delegate?.cencelTrip() 
        case .getDirections:
            print("Debug: Handle Get Dirictions")
        case .pickup:
            print("Debug: Handle Pickup Passenger")
        case .dropOff:
            print("Debug: Handle Drop Off ")
        }
    }
    
    //MARK: - Helper functions
    
    func configUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requesRide
            actionButton.setTitle(buttonAction.description, for: .normal )
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger   {
                titleLabel.text = "En Rout To Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                buttonAction = .cencel
                actionButton.setTitle(buttonAction.description, for: .normal)
                titleLabel.text = "Driver En Route"
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfolabel.text = user.fullname
        case .pickupPassanger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else { return }
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "En Route To Distanation"
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DISTANATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal )
            }
        }
    }
}
