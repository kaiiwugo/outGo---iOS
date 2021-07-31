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
        case featured = 3
        case medium = 10
        case Max = 19
        }
    static let shared = ExplorePanelViewController()
    static var allEvents = [Event]()
    var featuredEvents = [Event]()
    @IBOutlet weak var nearMeCollectionView: UICollectionView!
    @IBOutlet weak var featuredCollectionView: UICollectionView!
    @IBOutlet weak var nearMeLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadCollection(notification:)), name: NSNotification.Name(rawValue: "loadCollection"), object: nil)
        setUp()
        setupCollection()
        loadAllEvents()
    }
    //initial load of all events
    func loadAllEvents() {
        let locationManager = CLLocationManager()
        if let currentLocation = locationManager.location {
            ExplorePanelHandler.shared.loadEvents(limit: EventAmount.Max.rawValue, userLocation: currentLocation) { result, removedID in
                DispatchQueue.main.async {
                    Self.allEvents = result
                    self.updateNearMe(updatingLocation: currentLocation)
                    self.updateFeatured(events: Self.allEvents)
                    self.nearMeCollectionView.reloadData()
                    //updates map pins
                    MapViewController.shared.loadPins(event: result, removed: removedID)
                    NotificationCenter.default.post(name: NSNotification.Name("loadAllEvents"), object: nil)
                    MapViewController.shared.setEventRegions(event: result)
                }
            }
        }
    }
    
    //Updates the "near me" collection
    func updateNearMe(limit: Int = 50, updatingLocation: CLLocation){
        if ExplorePanelViewController.allEvents.isEmpty == false {
            DispatchQueue.main.async {
                ExplorePanelHandler.shared.updateNearMe(limit: EventAmount.medium.rawValue, updatingLocation: updatingLocation, passedEvents: Self.allEvents) { result in
                    Self.allEvents = result
                }
            }
        }
    }
    
    func updateFeatured(events: [Event]){
        var filtered = events.sorted(by: { $0.current.attendance > $1.current.attendance })
        featuredEvents = Array(filtered.prefix(EventAmount.featured.rawValue))
        featuredCollectionView.reloadData()
    }
    @objc func loadCollection(notification: NSNotification) {
        featuredCollectionView.reloadData()
        self.nearMeCollectionView.reloadData()
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
            return featuredEvents.count
        }
        return Self.allEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nearMeCollectionView {
            let cell = nearMeCollectionView.dequeueReusableCell(withReuseIdentifier: ExplorePageCollectionViewCell.identifier, for: indexPath) as! ExplorePageCollectionViewCell
            let index = indexPath.row
            let event = Self.allEvents[index]
            let eventImage = event.properties.eventImage
            let timePassed = Utilities.shared.getTimePassed(postDate: event.properties.eventDate as NSDate)
            let distance = event.current.distance
            cell.configure(with: ExploreEventCell(eventImage: eventImage, timeSincePost: timePassed, distance: distance, eventType: event.properties.eventType, friendEvent: event.friendEvent))
            return cell
        }
        else {
            let cell = featuredCollectionView.dequeueReusableCell(withReuseIdentifier: ExplorePageCollectionViewCell.identifier, for: indexPath) as! ExplorePageCollectionViewCell
            let index = indexPath.row
            let event = featuredEvents[index]
            let eventImage = event.properties.eventImage
            let timePassed = Utilities.shared.getTimePassed(postDate: event.properties.eventDate as NSDate)
            let distance = event.current.distance
            let host = event.properties.host
            cell.configure(with: ExploreEventCell(eventImage: eventImage, timeSincePost: timePassed, distance: distance, eventType: event.properties.eventType, friendEvent: event.friendEvent))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == nearMeCollectionView {
            let index = indexPath.row
            let ViewEventeVC = ViewEventViewController(nibName: "ViewEventViewController", bundle: nil)
            ViewEventeVC.event = Self.allEvents[index]
            show(ViewEventeVC, sender: self)
        }
        else {
            let index = indexPath.row
            let ViewEventeVC = ViewEventViewController(nibName: "ViewEventViewController", bundle: nil)
            ViewEventeVC.event = featuredEvents[index]
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
