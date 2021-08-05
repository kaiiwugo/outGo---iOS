//
//  MapPinHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import Foundation
import UIKit
import Firebase
import MapKit

class MapPinHandler {
    let db = Firestore.firestore()
    enum Collection: String {
        case events = "All Events"
        case presets = "Preset Events"
            }
    static let shared = MapPinHandler()
    
    func addAttendance(postID : String, collection: Collection){
        let eventDocument = db.collection(collection.rawValue).document(postID)
        eventDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                var result: Event?
                do {
                    result = try document.data(as: Event.self)
                    let attendance = result?.current.attendance
                    eventDocument.setData(["current": ["attendance": attendance! + 1]], merge: true)
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    func removeAttendance(postID : String, collection: Collection){
        let eventDocument = db.collection(collection.rawValue).document(postID)
        eventDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                var result: Event?
                do {
                    result = try document.data(as: Event.self)
                    let attendance = result?.current.attendance
                    eventDocument.setData(["current": ["attendance": attendance! - 1]], merge: true)
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    func shouldUpdateDistance(oldLocation: CLLocation, newLocation: MKUserLocation){
        let new = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        if  getDistance(oldLocation: oldLocation, newLocation: new) > 0.1 {
            ExplorePanelHandler.shared.updateDistance(location: new) {
                let monitoredEvents = ExplorePanelViewController.allEvents
                var filtered = monitoredEvents.sorted(by: { $0.current.distance < $1.current.distance })
                filtered.prefix(20)
                MapViewController.shared.setEventRegions(event: Array(filtered))
                MapViewController.currentUserLocation = new
            }
        }
    }
    
    func getDistance(oldLocation: CLLocation, newLocation: CLLocation) -> Double {
        var distance: Double
        distance = oldLocation.distance(from: newLocation) //Distance in meters
        distance = distance * 0.00062137 //To miles
        return round(10*distance)/10 //Rounded
    }
    
    func daytime() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        if hour > 6 && hour < 16 {
            return true
        }
        else {
            return false
        }
      
    }
    
    
}

