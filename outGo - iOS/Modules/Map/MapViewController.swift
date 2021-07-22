//
//  MapViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import UIKit
import MapKit
import Firebase
import FloatingPanel
import CoreLocation
//import NotificationCenter


class MapViewController: UIViewController, FloatingPanelControllerDelegate, UICollectionViewDelegate {
    let userDefaults = UserDefaults.standard
    enum EventAmount: Int {
        case small = 5
        case medium = 10
        case large = 20
        }
    enum EventTypes: String {
        case personal = "personal"
        case social = "social"
        case community = "community"
        case active = "active"
        }
    var attendedEvent = [String]()
    static let shared = MapViewController()
    //outlets
    
    @IBOutlet weak var mapView: MKMapView!
    //location vars
    let manager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    static var pins = [CustomPointAnnotation]()
    static var personalPublicPins = [CustomPointAnnotation]()
    static var personalPrivatePins = [CustomPointAnnotation]()
    static var presetPins = [CustomPointAnnotation]()
    var presets = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadPersonalPins(notification:)), name: NSNotification.Name(rawValue: "loadPersonalPins"), object: nil)
        setNavigationBars()
        setPanel()
        setMap()
        loadPresets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func loadPersonalPins(notification: NSNotification) {
        let pins = mapView.annotations
        mapView.removeAnnotations(pins)
        mapView.addAnnotations(Self.personalPublicPins)
        mapView.addAnnotations(Self.personalPrivatePins)
        mapView.addAnnotations(Self.presetPins)
    }
    
    func loadPins(event: [Event], removed: String){
        if removed != "" {
            removePin(event: event, removed: removed)
        }
        else {
            Self.personalPublicPins = []
            Self.personalPrivatePins = []
            event.forEach { event in
                let annotation = CustomPointAnnotation()
                annotation.isActive = event.current.isActive
                annotation.isPublic = event.current.isPublic
                annotation.eventType = event.properties.eventType
                annotation.pinID = event.properties.postID
                do {
                    let adress = try Utilities.shared.getAddress(Address: .standard, location: event.properties.eventLocation) { result in
                        annotation.subtitle = "\(result)"
                    }
                }
                catch {
                    print(error)
                }
                annotation.title = "\(event.properties.host)"
                annotation.coordinate = CLLocationCoordinate2D(latitude: event.coordinates.latitude, longitude: event.coordinates.longitude)
                addPin(pin: annotation)
            }
        }
    }
    
    func removePin(event: [Event], removed: String){
        event.forEach { event in
            if (event.properties.eventType == "personal") && event.current.isPublic == true {
                let index: Int = Self.personalPublicPins.firstIndex { pin in
                    pin.pinID == removed
                } ?? -1
                if index != -1 {
                    Self.personalPublicPins.remove(at: index)
                }
            }
            else {
                let index: Int = Self.personalPrivatePins.firstIndex { pin in
                    pin.pinID == removed
                } ?? -1
                if index != -1 {
                    Self.personalPrivatePins.remove(at: index)
                }
            }
        }
    }
    func addPin(pin: CustomPointAnnotation){
        let eventType = pin.eventType
        if (eventType == "personal") && pin.isPublic == true {
            Self.personalPublicPins.append(pin)
        }
        else {
            Self.personalPrivatePins.append(pin)
        }
    }
    
    func loadPresets(){
        FirestoreService.shared.getPresetEvents { result in
            DispatchQueue.main.async {
                result.forEach { event in
                    let annotation = CustomPointAnnotation()
                    annotation.isActive = event.current.isActive
                    annotation.isPublic = event.current.isPublic
                    annotation.eventType = event.properties.eventType
                    annotation.pinID = event.properties.postID
                    do {
                        let adress = try Utilities.shared.getAddress(Address: .standard, location: event.properties.eventLocation) { result in
                            annotation.subtitle = "\(result)"
                        }
                    }
                    catch {
                        print(error)
                    }
                    annotation.title = "\(event.properties.host)"
                    annotation.coordinate = CLLocationCoordinate2D(latitude: event.coordinates.latitude, longitude: event.coordinates.longitude)
                    self.mapView.addAnnotation(annotation)
                    Self.presetPins.append(annotation)
                }
            }
        }
    }

    func setNavigationBars(){
        //sets navigation bar
        self.title = "Map"
        self.navigationController?.navigationBar.tintColor = UIColor.label
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!]
        //makes bar clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        //Adds buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .plain, target: self, action: #selector(currentLocationButton))
        self.navigationItem.rightBarButtonItem?.tintColor = .label
        //Sets tab bar image
        self.tabBarController?.tabBar.items![0].image = UIImage(systemName: "map")
        self.tabBarController?.tabBar.items![1].image = UIImage(systemName: "person.3")
        self.tabBarController?.tabBar.items![0].setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 12)!], for: .normal)
        self.tabBarController?.tabBar.items![1].setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 12)!], for: .normal)
    }
    
    func setPanel(){
        var fpc: FloatingPanelController!
        fpc = FloatingPanelController()
        fpc.layout = MyFloatingPanelLayout()
        fpc.delegate = self
        //Appearance of fp
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.75)  
        fpc.surfaceView.appearance = appearance
        // Add a content view controller.
        fpc.set(contentViewController: ExplorePanelViewController())
        let content = ExplorePanelViewController()
        fpc.show(content, sender: nil)
        // Add the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
    }
    
    func setMap(){
        //Sets up map delegate tools
        mapView.delegate = self
        mapView.showAnnotations(mapView.annotations, animated: true)
        self.mapView.showsUserLocation = true;
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //more stress on battery
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    //Button Functions
    @objc func currentLocationButton(sender: UIBarButtonItem) {
        if let location = mapView.userLocation.location {
            render(location)
        }
    }
    //Attendence of events
    func setEventRegions (event: [Event]){
        var regionCenters = [CLLocationCoordinate2D]()
        event.forEach { event in
            monitorRegionAtLocation(center: event.properties.eventLocation2d, identifier: event.properties.postID)
        }
    }
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // Register the region.
            let distance = CLLocationDistance(50)
            let region = CLCircularRegion(center: center,
                 radius: distance, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            manager.startMonitoring(for: region)
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let eventID = region.identifier
            if state == .inside {
                addAttendence(eventID: eventID)
            }
            if attendedEvent.contains(eventID) == true && state == .outside {
                removeAttendence(eventID: eventID)
            }
        }
    }
    
    func addAttendence(eventID: String){
        if attendedEvent.contains(eventID) == false {
            MapPinHandler.shared.addAttendance(postID: eventID, collection: .events)
            attendedEvent.append(eventID)
        }
    }
    func removeAttendence(eventID: String){
        let index: Int = attendedEvent.firstIndex { event in
            event == eventID
        } ?? 0
        if attendedEvent[index] != nil {
            attendedEvent.remove(at: index)
            MapPinHandler.shared.removeAttendance(postID: eventID, collection: .events)
        }
    }

}

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "identifier")
        if let customAnnotation = annotation as? CustomPointAnnotation {
            annotationView.image = customAnnotation.setImage(eventType: customAnnotation.eventType)
            if customAnnotation.isActive == false {
                annotationView.alpha = 0.25
            }
            annotationView.canShowCallout = true
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let customAnnotation = view.annotation as? CustomPointAnnotation {
            let pinID = customAnnotation.pinID
            var event: Event?
            if customAnnotation.eventType == "personal" {
                event = ExplorePanelViewController.sharedEvent.first { Event in
                    Event.properties.postID == pinID
                }
            }
            else {
                event = ExplorePanelViewController.sharedPresetEvent.first { event in
                    event.properties.postID == pinID
                }
            }
            let ViewEventeVC = ViewEventViewController(nibName: "ViewEventViewController", bundle: nil)
            ViewEventeVC.event = event
            show(ViewEventeVC, sender: self)
        }
    }
    
    //updates center location, updates explore collection
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let viewLocation2D = mapView.centerCoordinate
        let viewLocation = CLLocation(latitude: viewLocation2D.latitude, longitude: viewLocation2D.longitude)
            ExplorePanelViewController.shared.updateNearMe(updatingLocation: viewLocation)
            NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
    }
    
    //passes in current location, then calls render function with said location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    //zooms into the user using their current lcoation
    func render(_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}


