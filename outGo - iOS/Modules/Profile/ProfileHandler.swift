//
//  ProfileHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/28/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import CoreLocation

class ProfileHandler {
    enum Collection: String {
        case events = "All Events"
        case presets = "Preset Events"
            }
    let db = Firestore.firestore()
    static let shared = ProfileHandler()
    
    func getMyEvents(user: String, completion: @escaping ([Event]) -> Void){
        FirestoreService.shared.getFriends { result in
            var userFriend = [String]()
            result.forEach { user in
                userFriend.append(user.userName)
            }
            var events = [Event]()
            self.db.collection(Collection.events.rawValue).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    DispatchQueue.global().async {
                        querySnapshot?.documents.forEach({ document in
                            var result: Event?
                            do {
                                result = try document.data(as: Event.self)
                                if user == result?.properties.host || userFriend.contains((result?.properties.host)!) {
                                    //sets coordinates
                                    let lat = result?.coordinates.latitude
                                    let long = result?.coordinates.longitude
                                    result?.properties.eventLocation = CLLocation(latitude: lat!, longitude: long!)
                                    result?.properties.eventLocation2d = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                                    //sets active status
                                    if round(Date().timeIntervalSince(result?.properties.eventDate ?? Date() as Date)) < 0 {
                                        result?.current.isActive = false
                                    }
                                    //gets image
                                    let url = URL(string: result!.properties.imageURL)
                                    let data = try? Data(contentsOf: url!)
                                    if data == nil {
                                        result?.properties.eventImage = UIImage(named: "RedPin")!
                                    }
                                    else {
                                        result?.properties.eventImage = UIImage(data: data!) ?? UIImage(named: "RedPin")!
                                    }
                                    if result?.properties.host != user {
                                        result?.friendEvent = true
                                    }
                                    if let result = result {
                                        if result.properties.host == user {
                                            events.insert(result, at: 0)
                                        }
                                        else {
                                            events.append(result)
                                        }
                                    }
                                }
                            }
                            catch{
                                print(error)
                            }
                            completion(events)
                        })
                    }
                }
            }
        }
    }
        
        
}
