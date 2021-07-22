//
//  FirestoreService.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import CoreLocation

class FirestoreService {
    enum Collection: String {
        case events = "All Events"
        case presets = "Preset Events"
            }
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let db = Firestore.firestore()
    static let shared = FirestoreService()
    private init() {}
    
    func getAllEvents(completion: @escaping ([Event], String) -> Void){
        getFriends { result in
            var userFriend = [String]()
            result.forEach { user in
                userFriend.append(user.userName)
            }
            var events = [Event]()
            self.db.collection(Collection.events.rawValue).addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    DispatchQueue.global().async {
                        querySnapshot?.documentChanges.forEach { diff in
                            if (diff.type == .added) {
                                var result: Event?
                                do {
                                    result = try diff.document.data(as: Event.self)
                                    if result?.current.isPublic == false && userFriend.contains((result?.properties.host)!) == false && result?.properties.host != self.currentUser {
                                    }
                                    else {
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
                                        if let result = result {
                                            events.append(result)
                                        }
                                    }
                                }
                                catch {
                                    print(error)
                                }
                            }
                            completion(events, "")
                            
                            if (diff.type == .modified) {
                            }
                            
                            if (diff.type == .removed) {
                                let removedID = diff.document.documentID
                                let index: Int = events.firstIndex { event in
                                    event.properties.postID == removedID
                                } ?? 0
                                if events[index] != nil {
                                    events.remove(at: index)
                                    completion(events, removedID)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getEventComments(postID : String, completion: @escaping ([Comments]) -> Void){
        db.collection(Collection.events.rawValue).document(postID).getDocument { (document, error) in
            if let document = document, document.exists {
                var result: Event?
                do {
                    result = try document.data(as: Event.self)
                    let comment = result?.comments
                    if let result = result {
                        completion(comment ?? [])
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    func getEventLikes(postID: String, collection: Collection, completion: @escaping (Int) -> Void){
        db.collection(collection.rawValue).document(postID).getDocument { (document, error) in
            if let document = document, document.exists {
                var result: Event?
                do {
                    result = try document.data(as: Event.self)
                    let likes = result?.current.attendance
                    if let result = result {
                        completion(likes!)
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    func deleteEvent(postID : String) {
        db.collection(Collection.events.rawValue).document(postID).delete()
    }
    
    func getFriends(completion: @escaping ([UserProfile]) -> Void){
        var friends = [UserProfile]()
        let authID = Auth.auth().currentUser
        if authID == nil {
            completion([])
        }
        else {
            let userID = String(authID!.uid)
            let userFriends = self.db.collection("Users").document(userID).collection("friends").getDocuments { snapshot, error in
                if error == nil && snapshot != nil {
                    for document in snapshot!.documents {
                        var result: UserProfile?
                        do {
                            result = try document.data(as: UserProfile.self)
                            if let result = result {
                                friends.append(result)
                            }
                        }
                        catch {
                            print(error)
                        }
                    }
                    completion(friends)
                }
            }
        }
    }
    
    func getPresetEvents(completion: @escaping ([Event]) -> Void){
        var events = [Event]()
        self.db.collection(Collection.presets.rawValue).getDocuments { (querySnapshot, err) in
            if err == nil && querySnapshot != nil {
                DispatchQueue.global().async {
                for document in querySnapshot!.documents {
                        var result: Event?
                        do {
                            result = try document.data(as: Event.self)
                            //get coordinates
                            let lat = result?.coordinates.latitude
                            let long = result?.coordinates.longitude
                            result?.properties.eventLocation = CLLocation(latitude: lat!, longitude: long!)
                            result?.properties.eventLocation2d = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                            //gets image
                            let eventUrl = result!.properties.imageURL
                            if eventUrl != "" {
                                let url = URL(string: result!.properties.imageURL)
                                let data = try? Data(contentsOf: url!)
                                if data == nil {
                                    result?.properties.eventImage = UIImage(systemName: "wifi.slash")!
                                }
                                else {
                                    result?.properties.eventImage = UIImage(data: data!) ?? UIImage(systemName: "wifi.slash")!
                                }
                            }
                            else {
                                let host = result?.properties.host
                                result?.properties.eventImage = UIImage(named: host!)!
                            }
                            
                            if let result = result {
                                events.append(result)
                            }
                        }
                        catch {
                            print(error)
                        }
                    }
                completion(events)
                }
            }
        }
    }
}
