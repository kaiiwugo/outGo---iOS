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
        case users = "Users"
        case circle = "Circles"
        case friends = "Friends"
    }
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let userGroup = UserDefaults.standard.string(forKey: "groupName")
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
                                    if self.eventExpiredCheck(createdAt: (result?.properties.eventDate)!, docID: diff.document.documentID) == false {
                                        if userFriend.contains((result?.properties.host)!) {
                                            result?.visability.friendEvent = true
                                        }
                                        if (result?.visability.isPublic == false && result?.visability.friendEvent == false && result?.properties.host != self.currentUser) || (self.groupEventCheck(check: (result?.visability.groupEvent)!) == false) {/*dont post*/}
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
                                                result?.properties.eventImage = UIImage(systemName: "wifi.slash")!.withTintColor(.white)
                                            }
                                            else {
                                                result?.properties.eventImage = UIImage(data: data!) ?? UIImage(named: "BluePin")!
                                            }
                                            if let result = result {
                                                events.append(result)
                                            }
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
                                } ?? -1
                                if index != -1 {
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
    func eventExpiredCheck(createdAt: Date, docID: String) -> Bool {
        if round(Date().timeIntervalSince(createdAt as Date)) > 86400 {
            self.db.collection(Collection.events.rawValue).document(docID).delete()
            return true
        }
        else {
            return false
        }
    }
    func groupEventCheck(check: Bool) -> Bool {
        if check == true && userGroup! == "" {
            return false
        }
        else {
            return true
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
    
    func getFriends(completion: @escaping ([UserProfile]) -> Void){
        var friends = [UserProfile]()
        let authID = Auth.auth().currentUser
        if authID == nil {
            completion([])
        }
        else {
            let userID = String(authID!.uid)
            let userFriends = self.db.collection(Collection.circle.rawValue).document(currentUser!).collection(Collection.friends.rawValue).getDocuments { snapshot, error in
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
    
    
    func deleteEvent(postID : String) {
        db.collection(Collection.events.rawValue).document(postID).delete()
    }

}
