//
//  HomeViewController.swift
//  UBER
//
//  Created by MacBook Pro on 06/09/23.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

private let annotationIdentifier = "DriverAnnotation"
class HomeViewController: UIViewController {
        
    //MARK: - Properties
    private let mapView =  MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputactivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableVeiw = UITableView()
    private var searchResults = [MKPlacemark]()
    
    private  final let locationInputHeight: CGFloat  = 230
    
    private var  user: User? {
        didSet { locationInputView.user = user }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        checkIfLoggedIn()
    }
    //MARK: - API
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        Servece.shared.fetchUserData(uid: uid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers () {
        guard let location = locationManager?.location else { return }
        Servece.shared.fetchDrivers (location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordenate: coordinate)
                        return true
                    }
                        return false
                    })
                }
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    func checkIfLoggedIn() {
        if Auth.auth().currentUser?.uid  == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
           configure()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } catch {
            print("DEBUG: Error singing out ")
        }
    }
    
    // MARK: - Helper functions
    func configure() {
        configurUI()
        fetchUserData()
        fetchDrivers()
    }
    func configurUI() {
        configureMapView()
        view.addSubview(inputactivationView)
        inputactivationView.centerX(inView: view)
        inputactivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputactivationView.ancher(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        inputactivationView.alpha = 0
        inputactivationView.delegate = self
        locationInputView.delegate = self
        UIView.animate(withDuration: 2) {
            self.inputactivationView.alpha = 1
        }
        configureTableVeiw()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configurelocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.ancher(top: view.topAnchor,
                                 left: view.leftAnchor,
                                 right: view.rightAnchor,
                                 height: locationInputHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5) { [self] in
            locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.6) {
                self.tableVeiw.frame.origin.y = self.locationInputHeight
            }
        }
    }
    func configureTableVeiw() {
        tableVeiw.delegate = self
        tableVeiw.dataSource = self
        
        tableVeiw.register(LocationCell.self,
                            forCellReuseIdentifier: LocationCell.reuseIdentifier)
        tableVeiw.rowHeight = 60
        tableVeiw.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputHeight
        tableVeiw.frame = CGRect(x: 0,
                                 y: view.frame.height ,
                                 width: view.frame.width,
                                 height: height)
        view.addSubview(tableVeiw )
    }
    
    func dismissLocationInputView(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableVeiw.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.inputactivationView.alpha = 1
            })
          }, completion: completion)
        }
    }


//MARK: - MAP Helper functions

private extension HomeViewController {
    func searchBy(naturalLanguageQuery: String, complition: @escaping([MKPlacemark]) -> Void) {
        var resoults = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return}
            response.mapItems.forEach { item in
                resoults.append(item.placemark)
            }
            complition(resoults)
        }
    }
}
// MARK: - MKMapViewDelegate

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(
                annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image =  UIImage(systemName: "car.side.fill")
            return view
        }
        return nil
    }
}
//MARK: - Location Services
extension HomeViewController  {
    func enableLocationServices() {
    switch  locationManager?.authorizationStatus {
        case .notDetermined:
            print("Debug: Not determined ..")
            locationManager?.requestWhenInUseAuthorization()
        case .denied , .restricted:
            break
        case .authorizedAlways:
            print("Debug: Auth always ..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("Debug: Auth when in use ..")
            locationManager?.requestAlwaysAuthorization()
       default: break
        }
    }
}

//MARK: - LocationInputActivationViewDelegate
extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
         inputactivationView.alpha = 0
         configurelocationInputView()
    }
}
// MARK: - LocationViewDelegate
extension HomeViewController: LocationInputViewDelegate {
    func dismissLocationInputView() {
       dismissLocationInputView()
    }
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { results in
            self.searchResults = results
            self.tableVeiw.reloadData()
        }
    }
    
    
    
    
    
}

//MARK: - UITableViewDelegate UITableViewDataSource

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row ]
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  "Test"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Debug: tapped \( indexPath.row )")
    }
}
