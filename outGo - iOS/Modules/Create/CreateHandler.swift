//
//  CreateHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/30/21.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseStorage


class CreateHandler {
    static let shared = CreateHandler()
    let storage = Storage.storage().reference()
    
    func getImageURL(imageData: Data, date: Date, completion: @escaping (String) -> Void){
        //Uploads Image to db and gets download url
        storage.child("EventImages/User/\(date)").putData(imageData, metadata: nil, completion:  {_, error in
            guard error == nil else {
                print("ERROR")
                return
            }
            self.storage.child("EventImages/User/\(date)").downloadURL { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let imageUrl = url.absoluteString
                completion(imageUrl)
            }
        })
    }
    
    func eventDistanceCheck(lat: Double, long: Double, isPublic: Bool, groupEvent: Bool) -> Bool{
        let eventLocation = CLLocation(latitude: lat, longitude: long)
        if ExplorePanelViewController.allEvents.isEmpty == false {
            let event = ExplorePanelViewController.allEvents[0]
            if getDistance(myEventLocation: eventLocation, eventLocation: event.properties.eventLocation) < 100 && (event.visability.isPublic == isPublic || event.visability.groupEvent == groupEvent) {
                return false
            }
            return true
        }
        else {
            return true
        }
    }
    
    func getDistance(myEventLocation: CLLocation, eventLocation: CLLocation) -> Double {
        var distance: Double
        distance = myEventLocation.distance(from: eventLocation) //Distance in meters
        return distance
    }
    
}
