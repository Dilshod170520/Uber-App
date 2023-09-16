//
//  PickupController.swift
//  UBER
//
//  Created by MacBook Pro on 16/09/23.
//

import UIKit
import MapKit

protocol PickupcontrollerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {

    //MARK: - Properties
    
    weak var delagete: PickupcontrollerDelegate?
    private let mapView = MKMapView()
    let trip: Trip?
    
    private let cencelBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Would you like to pickup this passenger"
        return label
    }()
    
    private let accepteTripBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept Trip", for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return button
    }()
    
    init(trip: Trip?) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurUI()
        configureMapView()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //MARK: - Selecters
    @objc func handleDismissal() {
        dismiss(animated: true)
    } 
    
    @objc func handleAcceptTrip() {
        guard let trip = trip else { return }
        Service.shared.acceptTrip(trip: trip) { Error, ref in
            self.delagete?.didAcceptTrip(trip)
        }
    }
    //MARK: - API

    //MARK: - Helper function
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: (trip?.pickupCoordinate)!,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        guard let tripCoordinate = trip?.pickupCoordinate else { return}
        
        let anno  = MKPointAnnotation()
        anno.coordinate = tripCoordinate
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
    func configurUI() {
        view.backgroundColor = .black
        
        view.addSubview(cencelBtn)
        cencelBtn.ancher(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270 / 2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -170)
         
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.ancher(top: mapView.bottomAnchor,
                           paddingTop: 16)
        
        view.addSubview(accepteTripBtn)
        accepteTripBtn.ancher(top: pickupLabel.bottomAnchor,
                              left: view.leftAnchor,
                              right: view.rightAnchor ,
                              paddingTop: 20 ,
                              paddingLeft: 32,
                              paddingRight: 32,
                              height: 50)
    }
}
