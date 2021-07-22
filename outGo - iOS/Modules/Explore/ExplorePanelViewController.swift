//
//  ExplorePanelViewController.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import UIKit
import FloatingPanel
import MapKit
import CoreLocation

class ExplorePanelViewController: UIViewController, CLLocationManagerDelegate {
    enum EventAmount: Int {
        case small = 5
        case medium = 10
        case large = 20
        }
    static let shared = ExplorePanelViewController()
    static var sharedEvent = [Event]()
    static var sharedPresetEvent = [Event]()
    @IBOutlet weak var nearMeCollectionView: UICollectionView!
    @IBOutlet weak var featuredCollectionView: UICollectionView!
    @IBOutlet weak var nearMeLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadCollection(notification:)), name: NSNotification.Name(rawValue: "load"), object: nil)
        setUp()
        setupCollection()
        self.loadAllEvents()
        self.loadPresets()
    
    }
    
    func loadAllEvents() {
        let locationManager = CLLocationManager()
        if let currentLocation = locationManager.location {
            ExplorePanelHandler.shared.loadEvents(limit: EventAmount.medium.rawValue, userLocation: currentLocation) { result, removedID in
                DispatchQueue.main.async {
                    Self.sharedEvent = result
                    Self.sharedEvent.append(contentsOf: Self.sharedPresetEvent)
                    self.nearMeCollectionView.reloadData()
                    MapViewController.shared.loadPins(event: result, removed: removedID)
                    NotificationCenter.default.post(name: NSNotification.Name("loadPersonalPins"), object: nil)
                    MapViewController.shared.setEventRegions(event: result)
                }
            }
        }
    }
    
    //sets featured
    func loadPresets(){
        let locationManager = CLLocationManager()
        if let currentLocation = locationManager.location {
            ExplorePanelHandler.shared.loadPresets(limit: EventAmount.medium.rawValue, userLocation: currentLocation) { result in
                DispatchQueue.main.async {
                    Self.sharedPresetEvent = result
                    Self.sharedEvent.append(contentsOf: result)
                    //self.nearMeCollectionView.reloadData()
                    self.featuredCollectionView.reloadData()
                }
            }
        }
    }
    
    //Want to change use of static var here. Need somewhere to store list of all events, so don't have to load from firebase more than once
    func updateNearMe(limit: Int = 50, updatingLocation: CLLocation){
        if ExplorePanelViewController.sharedEvent.isEmpty == false {
            DispatchQueue.main.async {
                ExplorePanelHandler.shared.updateNearMe(limit: EventAmount.medium.rawValue, updatingLocation: updatingLocation, passedEvents: Self.sharedEvent) { result in
                    Self.sharedEvent = result
                }
            }
        }
    }
    
    @IBAction func createButton(_ sender: Any) {
        let createVC = CreateEventViewController(nibName: "CreateEventViewController", bundle: nil)
        show(createVC, sender: self)
    }
    
    func setUp(){
        createButton.layer.cornerRadius = 10
        createButton.tintColor = .label
        createButton.clipsToBounds = true
    }
    
    @objc func loadCollection(notification: NSNotification) {
      self.nearMeCollectionView.reloadData()
    }
    
    func setupCollection(){
        //near me
        nearMeCollectionView.layer.cornerRadius = 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        nearMeCollectionView.backgroundColor = .clear
        nearMeCollectionView.showsHorizontalScrollIndicator = false
        nearMeCollectionView.collectionViewLayout = layout
        nearMeCollectionView.dataSource = self
        nearMeCollectionView.delegate = self
        nearMeCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        nearMeCollectionView.register(ExplorePageCollectionViewCell.nib(), forCellWithReuseIdentifier: ExplorePageCollectionViewCell.identifier)
        //featured
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        featuredCollectionView.layer.cornerRadius = 10
        featuredCollectionView.backgroundColor = .clear
        featuredCollectionView.collectionViewLayout = layout2
        featuredCollectionView.dataSource = self
        featuredCollectionView.delegate = self
        featuredCollectionView.showsHorizontalScrollIndicator = false
        featuredCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        featuredCollectionView.register(ExplorePageCollectionViewCell.nib(), forCellWithReuseIdentifier: ExplorePageCollectionViewCell.identifier)
    }

}

extension ExplorePanelViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuredCollectionView {
            return Self.sharedPresetEvent.count
        }
        return Self.sharedEvent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nearMeCollectionView {
            let cell = nearMeCollectionView.dequeueReusableCell(withReuseIdentifier: ExplorePageCollectionViewCell.identifier, for: indexPath) as! ExplorePageCollectionViewCell
            let index = indexPath.row
            let event = Self.sharedEvent[index]
            let eventImage = event.properties.eventImage
            let timePassed = Utilities.shared.getTimePassed(postDate: event.properties.eventDate as NSDate)
            let distance = event.current.distance
            cell.configure(with: ExploreEventCell(eventImage: eventImage, timeSincePost: timePassed, distance: distance, eventType: event.properties.eventType))
            return cell
        }
        else {
            let cell = featuredCollectionView.dequeueReusableCell(withReuseIdentifier: ExplorePageCollectionViewCell.identifier, for: indexPath) as! ExplorePageCollectionViewCell
            let index = indexPath.row
            let event = Self.sharedPresetEvent[index]
            let eventImage = UIImage(named: "\(event.properties.host)")!
            let timePassed = ""
            let distance = event.current.distance
            cell.configure(with: ExploreEventCell(eventImage: eventImage, timeSincePost: timePassed, distance: distance, eventType: event.properties.eventType))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == nearMeCollectionView {
            let index = indexPath.row
            let ViewEventeVC = ViewEventViewController(nibName: "ViewEventViewController", bundle: nil)
            ViewEventeVC.event = Self.sharedEvent[index]
            show(ViewEventeVC, sender: self)
        }
        else {
            let index = indexPath.row
            let ViewEventeVC = ViewEventViewController(nibName: "ViewEventViewController", bundle: nil)
            ViewEventeVC.event = Self.sharedPresetEvent[index]
            show(ViewEventeVC, sender: self)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 200)
    }
}

//Controls the explore page
class MyFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 270, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 70.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
