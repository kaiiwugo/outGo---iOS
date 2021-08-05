//
//  FriendingHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/16/21.
//

import Foundation
import FirebaseFirestore
import Firebase


class FriendingHandler {
    enum Collection: String {
        case events = "All Events"
        case users = "Users"
        case circle = "Circles"
        case friends = "Friends"
        case requests = "Requests"
    }
    
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let db = Firestore.firestore()
    static let shared = FriendingHandler()
    
    func getAllUsers(completion: @escaping ([UserProfile]) -> Void){
        var userFriend = [String]()
        FirestoreService.shared.getFriends { result in
            result.forEach { user in
                userFriend.append(user.userName)
            }
            var user = [UserProfile]()
            self.db.collection(Collection.users.rawValue).getDocuments { snapshot, error in
                if error == nil && snapshot != nil {
                    for document in snapshot!.documents {
                        var result: UserProfile?
                        do {
                            result = try document.data(as: UserProfile.self)
                            if userFriend.contains(result!.userName) {
                                result?.isFriend = true
                            }
                            if let result = result {
                                if result.userName != self.currentUser {
                                    user.append(result)
                                }
                            }
                        }
                        catch {
                            print(error)
                        }
                    }
                    completion(user)
                }
            }
        }
    }
    
    func addFriend(friendName: String){
        userRequestCheck(friendName: friendName) { result in
            if result == false {
                self.makeRequest(friendName: friendName)
            }
            else { //adds them to your friends
                self.getUser(friendName: friendName) { user in
                    self.db.collection(Collection.circle.rawValue).document(self.currentUser!).collection(Collection.friends.rawValue).document(friendName).setData(["userName": friendName, "email": user.email, "userID": user.userID, "group": ["groupName": user.group.groupName, "groupID": user.group.groupID]])
                }
                self.getUser(friendName: self.currentUser!) { user in
                    self.db.collection(Collection.circle.rawValue).document(friendName).collection(Collection.friends.rawValue).document(self.currentUser!).setData(["userName": self.currentUser!, "email": user.email, "userID": user.userID, "group": ["groupName": user.group.groupName, "groupID": user.group.groupID]])
                }
            }
        }
    }
    
    func removeFriend(friendName: String){
        db.collection(Collection.circle.rawValue).document(friendName).collection(Collection.friends.rawValue).document(currentUser!).delete()
        db.collection(Collection.circle.rawValue).document(currentUser!).collection(Collection.friends.rawValue).document(friendName).delete()
    }
    
    func rejectUser(userName: String){
        db.collection(Collection.circle.rawValue).document(currentUser!).collection(Collection.requests.rawValue).document(userName).delete()
    }
    
    func getUser(friendName: String, completion: @escaping (UserProfile) -> Void){
        let user = db.collection(Collection.users.rawValue).document(friendName).getDocument { document, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var result: UserProfile?
                do {
                    result = try document?.data(as: UserProfile.self)
                }
                catch {
                    print(error)
                }
                if result?.userName != "" {
                    completion(result!)
                }
            }
        }
    }
    
    func userRequestCheck(friendName: String, completion: @escaping (Bool) -> Void){
        let request = db.collection(Collection.circle.rawValue).document(currentUser!).collection(Collection.requests.rawValue)
        var found = false
        request.getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                snapshot?.documents.forEach({ document in
                    if document.documentID == friendName {
                        found = true
                        request.document(document.documentID).delete()
                    }
                })
                completion(found)
            }
        }
    }
    
    func makeRequest(friendName: String){
        let request = db.collection(Collection.circle.rawValue).document(friendName).collection(Collection.requests.rawValue).document(currentUser!).setData(["Request" : true])
    }
    
    func allRequestCheck(completion: @escaping ([String]) -> Void){
        let request = db.collection(Collection.circle.rawValue).document(currentUser!).collection(Collection.requests.rawValue)
        var users = [String]()
        request.getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                for document in snapshot!.documents {
                    users.append(document.documentID)
                }
                completion(users)
            }
        }
    }
    
    func checkUserExists(user: String, completion: @escaping (Bool) -> Void){
        db.collection("Users").document(user).getDocument { snapshot, err in
            if snapshot?.exists == true && user != self.currentUser {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    
}
