//
//  HomeViewController.swift
//  UBER
//
//  Created by MacBook Pro on 06/09/23.
//

import UIKit
import Firebase
import MapKit

class HomeViewController: UIViewController {

    //MARK: - Properties
    private let mapView =  MKMapView()
    
    private let locationManager = CLLocationManager()
    
    private let inputactivationView = LocationInputActivationView()
        
     
 //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        checkIfLoggedIn()
       // signOut()
        view.backgroundColor = .red
    }
    
    //MARK: - API
    func checkIfLoggedIn() {
        if Auth.auth().currentUser?.uid  == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            configurUI()
        }
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch  {
            print("DEBUG: Error singing out ")
        }
    }
    
    // MARK: - Helper functions

    func configurUI() {
      configureMapView()
        
        view.addSubview(inputactivationView)
        inputactivationView.centerX(inView: view)
        inputactivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputactivationView.ancher(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
}
//MARK: - Location Services
extension HomeViewController: CLLocationManagerDelegate {
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch  CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Debug: Not determined ..")
            locationManager.requestWhenInUseAuthorization()
        case .denied , .restricted:
            break
        case .authorizedAlways:
            print("Debug: Auth always ..")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("Debug: Auth when in use ..")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
