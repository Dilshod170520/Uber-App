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

enum AnnotationType: String {
    case pickup
    case destation
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
                observeCurrentTrip()
            } else {
                observeTrip()
            }
        }
    }
    private var trip: Trip?  {
        didSet {
            guard let user =  user else { return}
            
            if user.accountType == .driver  {
                guard let trip = trip else { return}
                let controller = PickupController(trip: trip)
                controller.modalPresentationStyle = .fullScreen
                controller.delagete = self
                self.present(controller, animated: true)
            } else {
                print( "DEBUG: Show ride action view for accepted trip..")
            }
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
    //MARK: - Passenger API

    
    func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        PassengerService .shared.fetchDrivers (location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordenate: coordinate)
                        self.zoomActioveTrip(withDriverUid: driver.uid)
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
    
    func startTrip() {
        guard let trip = self.trip else { return}
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { err, ref in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlys()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinate)
            let  placemark = MKPlacemark(coordinate: trip.destinationCoordinate)
            let mapItem = MKMapItem(placemark: placemark)
            self.setCustomRegion(withType: .destation, coordinate: trip.destinationCoordinate)
            self.generatePolyline(toDestination: mapItem)
            
            self.mapView.zoomToFit(annotation: self.mapView.annotations )
        }
    }
    
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let state = trip.state else { return}
            guard let driverUid = trip.driverUid else { return }
            
            switch state {
            case .requested:
                break
            case .accepted:
                self.shouldPresentLocationView(false )
                self.removeAnnotationsAndOverlys()
                self.zoomActioveTrip(withDriverUid: driverUid)
                Service.shared.fetchUserData(uid: driverUid) { driver in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver )
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .arriveDestination:
                self.rideActionView.config = .endTrip
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .completed:
                self.animateRideActionView(shouldShow: false)
                self.centerMapOnUserLocation()
                self.configureActionBtn(config: .showMenu)
                self.inputactivationView.alpha = 1 
                self.presentAlertController(withTitle: "Trip Completed",
                                            messege: "We hope you enjoyed your trip")
            }
        }
    }
   
    //MARK: - Drivers API
    func observeTrip() {
        DriverService.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    func observeCanceledTrip(trip: Trip) {
        DriverService.shared.observeCencelled(trip: trip) {
            self.removeAnnotationsAndOverlys()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Ooops!",
                                        messege:  "The passenge has cencelled this trip ")
         }
    }
    
    //MARK: - Shared API
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        Service.shared.fetchUserData(uid: uid) { user in
            self.user = user
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
            self.actionBtn.setImage(UIImage(systemName: "text.justify"),
                                    for: .normal)
            self.actionbuttonConfig = .showMenu
        case .dismissActionView:
            self.actionBtn.setImage(UIImage(systemName: "arrow.left"),
                                    for: .normal)
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
        inputactivationView.setDimensions(height: 50,
                                          width: view.frame.width - 64)
        inputactivationView.ancher(top: actionBtn.bottomAnchor,
                                   paddingTop: 20)
        inputactivationView.alpha = 0
        inputactivationView.delegate = self
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
    
    func animateRideActionView(shouldShow: Bool, distination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil , user: User? = nil ) {
        let yOrigin = shouldShow ?  self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        if shouldShow {
            guard let config = config else { return }
            
            if let destination = distination {
                rideActionView.destination = destination
            }
            if let user = user {
                rideActionView.user = user
            }
            rideActionView.config = config
        }
    }
    
    func zoomActioveTrip(withDriverUid uid: String) {
        var annotations = [MKAnnotation]()
        self.mapView.annotations.forEach { annotation in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == uid {
                    annotations.append(anno)
                }
            }
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        self.mapView.zoomToFit(annotation: annotations)
        print("Debug: Annotations array is \(annotations)")
    }
    
    func dropOffPassenger() {
        guard let trip = self.trip else { return}
        
        DriverService.shared.updateTripState(trip: trip, state: .completed) { err, ref in
            self.removeAnnotationsAndOverlys()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
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
     func  removeAnnotationsAndOverlys() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return}
        
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
        
    }
    
    func setCustomRegion(withType type: AnnotationType,  coordinate: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinate, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
        
        print("Debug: Did set region \(region )")
    }
}

// MARK: - MKMapViewDelegate

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user  else { return }
        guard user.accountType ==  .driver else { return }
        guard let location = userLocation.location  else { return }
        
         DriverService .shared.updateDriverLocation(location: location)
    }
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
//MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("Debug: Did start manitoring pick up region")
        }
        if region.identifier == AnnotationType.destation.rawValue {
            print("Debug: Did start manitoring destanition region")
        }
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = self.trip else {return}

        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { err, ref in
                self.rideActionView.config = .endTrip
            }
        }
        if region.identifier == AnnotationType.destation.rawValue {
            print("Debug: Did start manitoring destanition region")

        }
        
    }
    
    func enableLocationServices() {
        locationManager?.delegate = self
         
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
            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
             let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            self.mapView.zoomToFit(annotation: annotations)
            
            self.animateRideActionView(shouldShow: true,
                                       distination: selectedPlacemark, config: .requestRide)
        }
    }
}

//MARK: - RideActionViewDelegate
extension HomeViewController: RideActionViewDelegate {
   
    
    func uploudTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        
        shouldPresentLocationView(true, massege: "Finding you a ride..")
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (err, ref) in
            if let error = err {
                print("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.rideActionView.frame.origin.y = self.view.frame.height
            })
        }
    }
    func cencelTrip() {
        PassengerService.shared.deleteTrip { error, ref in
            if let error = error {
                print("Debug:  Error deleting .....>>>>>> \(error.localizedDescription)")
                return
            }
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlys()
            
            self.actionBtn.setImage(UIImage(systemName: "text.justify"), for: .normal)
            self.actionbuttonConfig = .showMenu
            self.inputactivationView.alpha = 1
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
}

//MARK: - PickupcontrollerDelegate
extension HomeViewController: PickupcontrollerDelegate {
  
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip
        
        self.mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinate)
        setCustomRegion(withType: .pickup, coordinate: trip.pickupCoordinate)

        let placemark = MKPlacemark(coordinate: trip.pickupCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        mapView.zoomToFit(annotation: mapView.annotations)

        observeCanceledTrip(trip: trip)
         
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
    
}
