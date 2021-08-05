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
    static let shared = MapViewController()
    @IBOutlet weak var mapView: MKMapView!
    var attendedEvent = [String]()
    //location vars
    let manager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    static var currentUserLocation = CLLocation()
    static var publicPins = [CustomPointAnnotation]()
    static var privatePins = [CustomPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadAllEvents(notification:)), name: NSNotification.Name(rawValue: "loadAllEvents"), object: nil)
        setNavigationBars()
        setPanel()
        setMap()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func loadAllEvents(notification: NSNotification) {
        let pins = mapView.annotations
        mapView.removeAnnotations(pins)
        mapView.addAnnotations(Self.publicPins)
        mapView.addAnnotations(Self.privatePins)
    }
    
    func loadPins(event: [Event], removed: String){
        if removed != "" {
            removePin(event: event, removed: removed)
        }
        else {
            Self.publicPins = []
            Self.privatePins = []
            event.forEach { event in
                let annotation = CustomPointAnnotation()
                annotation.isActive = event.current.isActive
                annotation.isPublic = event.visability.isPublic
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
            if event.visability.isPublic == true {
                let index: Int = Self.publicPins.firstIndex { pin in
                    pin.pinID == removed
                } ?? -1
                if index != -1 {
                    Self.publicPins.remove(at: index)
                }
            }
            else {
                let index: Int = Self.privatePins.firstIndex { pin in
                    pin.pinID == removed
                } ?? -1
                if index != -1 {
                    Self.privatePins.remove(at: index)
                }
            }
        }
    }
    func addPin(pin: CustomPointAnnotation){
        if pin.isPublic == true {
            Self.publicPins.append(pin)
        }
        else{
            Self.privatePins.append(pin)
        }
    }

    func setNavigationBars(){
        //sets navigation bar
        self.title = "Map"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!, .foregroundColor: UIColor.white]
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationItem.backBarButtonItem = backBarButtonItem
        //makes bar clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "RedFade"), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        //Adds buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "location.fill"), style: .plain, target: self, action: #selector(currentLocationButton))
        self.navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func setPanel(){
        var fpc: FloatingPanelController!
        fpc = FloatingPanelController()
        fpc.layout = MyFloatingPanelLayout()
        fpc.delegate = self
        //Appearance of fp
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.75)
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
        if MapPinHandler.shared.daytime() == true {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
        }
    }
    //Button Functions
    @objc func currentLocationButton(sender: UIBarButtonItem) {
        if let location = mapView.userLocation.location {
            render(location)
        }
    }
    
    //Attendence of events
    func setEventRegions (event: [Event]){
        let monitoredRegions = manager.monitoredRegions
        for region in monitoredRegions {
            manager.stopMonitoring(for: region)
        }
        event.forEach { event in
            monitorRegionAtLocation(center: event.properties.eventLocation2d, identifier: event.properties.postID)
        }
    }
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String ) {
        // Make sure the devices supports region monitoring.
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let distance = CLLocationDistance(50)
            let region = CLCircularRegion(center: center,
                                          radius: distance, identifier: identifier)
            // Register the region.
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
        } ?? -1
        if index != -1 {
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
    
    //handles updateing current distance from events + what event regions are monitored 
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //updates distance to events every .1 miles moved by user
        MapPinHandler.shared.shouldUpdateDistance(oldLocation: Self.currentUserLocation, newLocation: userLocation)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let customAnnotation = view.annotation as? CustomPointAnnotation {
            let pinID = customAnnotation.pinID
            var event: Event?
            event = ExplorePanelViewController.allEvents.first { Event in
                Event.properties.postID == pinID
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
            NotificationCenter.default.post(name: NSNotification.Name("loadCollection"), object: nil)
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
