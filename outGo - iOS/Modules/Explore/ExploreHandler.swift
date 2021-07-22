//
//  ExploreHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/25/21.
//

import Foundation
import MapKit

class ExplorePanelHandler{
    var events = [Event]()
    static let shared = ExplorePanelHandler()
    
    func loadPresets(limit: Int = 50, userLocation: CLLocation, completion: @escaping ([Event]) -> Void){
        FirestoreService.shared.getPresetEvents { result in
            if result.isEmpty == false {
                self.events = result
                let length = result.count - 1
                for i in 0...length {
                    self.events[i].current.distance = self.getDistance(userLocation: userLocation, eventLocation: result[i].properties.eventLocation)
                    self.events[i].properties.eventImage = UIImage(named: self.events[i].properties.host)!
                }
                completion(self.events)
            }
        }
    }
    
    //returns the top n closest events
    func loadEvents(limit: Int = 50, userLocation: CLLocation, completion: @escaping ([Event], String) -> Void){
        FirestoreService.shared.getAllEvents { result, removedID in
            if result.isEmpty == false {
                self.events = result
                let length = result.count - 1
                for i in 0...length {
                    self.events[i].current.distance = self.getDistance(userLocation: userLocation, eventLocation: result[i].properties.eventLocation)
                }
                let filteredEvents = self.events.sorted(by: { $0.current.viewDistance < $1.current.viewDistance })
                filteredEvents.prefix(limit)
                completion(Array(filteredEvents), removedID)
            }
        }
    }
    
    func updateNearMe(limit: Int = 50, updatingLocation: CLLocation, passedEvents: [Event], completion: @escaping ([Event]) -> Void) {
        let length = passedEvents.count - 1
        self.events = passedEvents
        for i in 0...length {
            self.events[i].current.viewDistance = self.getDistance(userLocation: updatingLocation, eventLocation: passedEvents[i].properties.eventLocation)
        }
        let filteredEvents = self.events.sorted(by: { $0.current.viewDistance < $1.current.viewDistance })
        filteredEvents.prefix(limit)
        completion(Array(filteredEvents))
    }
    
    func getDistance(userLocation: CLLocation, eventLocation: CLLocation) -> Double {
        var distance: Double
        distance = userLocation.distance(from: eventLocation) //Distance in meters
        distance = distance * 0.00062137 //To miles
        return round(10*distance)/10 //Rounded
    }
}
