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

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}
class HomeViewController: UIViewController {
        
    //MARK: - Properties
    private let mapView =  MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputactivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableVeiw = UITableView()
    private var searchResults = [MKPlacemark]()
    private  final let locationInputHeight: CGFloat  = 230
    private final let rideActionViewHeight: CGFloat = 300
    private var actionbuttonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    private var  user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
            } else {
                observeTrip()
            }
        }
    }
    private var trip: Trip?  {
        didSet {
            guard let trip = trip else { return}
            let controller = PickupController(trip: trip)
            controller.modalPresentationStyle = .fullScreen
            controller.delagete = self
            self.present(controller, animated: true)
        }
    }
    
    private let actionBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "text.justify") , for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(actionBtnPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        checkIfLoggedIn()
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return}
        print("Debug: acctept trip is \(trip.state)")
    }
    
    // MARK: - Selecters
    
    @objc func actionBtnPressed() {
        switch actionbuttonConfig {
        case .showMenu:
            print("show menu ")
        case .dismissActionView:
            self.removeAnnotationsAndOverlys()
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.inputactivationView.alpha = 1
                self.configureActionBtn(config: .showMenu)
                self.animateRideActionView(shouldShow: false )
            }
           
        }
    }
    //MARK: - API
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        Service.shared.fetchUserData(uid: uid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers () {
       
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers (location: location) { (driver) in
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
    
    func observeTrip() {
        Service.shared.observeTrips { trip in
            self.trip = trip
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
       
    }
    
   
    fileprivate func configureActionBtn(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionBtn.setImage(UIImage(systemName: "text.justify"), for: .normal)
            self.actionbuttonConfig = .showMenu
        case .dismissActionView:
            self.actionBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            self.actionbuttonConfig = .dismissActionView
        }
    }
    func configurUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionBtn)
        actionBtn.ancher(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         paddingLeft: 16,
                         width: 45,
                         height: 45)
      
        configureTableVeiw()
    }
    
    func configureLocationInputActivationView() {
        view.addSubview(inputactivationView)
        inputactivationView.centerX(inView: view)
        inputactivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputactivationView.ancher(top: actionBtn.bottomAnchor, paddingTop: 20)
        inputactivationView.alpha = 0
        inputactivationView.delegate = self
        // locationInputView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputactivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.delegate = self
        rideActionView.frame = CGRect(x: 0,
                                      y: view.frame.height,
                                      width: view.frame.width,
                                      height: rideActionViewHeight)
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
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableVeiw.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
           
          }, completion: completion)
        }
    
    func animateRideActionView(shouldShow: Bool, distination: MKPlacemark? = nil) {
        let yOrigin = shouldShow ?  self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        if shouldShow {
            guard let distination = distination else { return}
            self.rideActionView.destination = distination
        }
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
      }
    }


//MARK: - MAP Helper functions

private extension HomeViewController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach({ item in
                results.append(item.placemark)
            })
            completion(results)
        }
    }
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile

        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlys() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
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
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.inputactivationView.alpha = 1
            })
        }
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

        let selectedPlacemark = searchResults[indexPath.row]
        configureActionBtn(config: .dismissActionView )

        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)

        dismissLocationView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            let annotations = self.mapView.annotations.filter ( { !$0.isKind(of: DriverAnnotation.self) } )
            self.mapView.zoomToFit(annotation: annotations )
            
            self.animateRideActionView(shouldShow: true, distination: selectedPlacemark )
            
        }
    }
}

//MARK: - RideActionViewDelegate
extension HomeViewController: RideActionViewDelegate {
    
    func uploudTrip(_ view: RideActionView) {
        guard let pickupCoordinate = locationManager?.location?.coordinate else { return}
        guard let distanitionCoordinate = view.destination?.coordinate else { return}
        Service.shared.uploudTrip(pickupCoordinate, distanitionCoordinate) { (err, ref) in
            if let error = err {
                print("Debug: Feiled to uploud trip with error \( error)")
            }
            print("Debug: Did uploud saccessfully ")
        }
    }
}

//MARK: -
extension HomeViewController: PickupcontrollerDelegate {
  
    func didAcceptTrip(_ trip: Trip) {
        self.trip?.state = .accepted
        self.dismiss(animated: true)
   
    }
}
