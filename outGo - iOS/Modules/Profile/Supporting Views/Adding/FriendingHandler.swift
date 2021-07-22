//
//  FriendingHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/16/21.
//

import Foundation
import FirebaseFirestore


class FriendingHandler {
    let currentUser = UserDefaults.standard.string(forKey: "currentUser")
    let db = Firestore.firestore()
    static let shared = FriendingHandler()
    
    func test(){
        let allUsers = self.db.collection("Users")
        allUsers.getDocuments { (snapshot, err) in
            print(snapshot)
            for documents in snapshot!.documents {
                print("why god")
            }
        }
        print(allUsers.document("tCJYcGoSC7dusmUVQgesZTYOZI32").documentID)
    

    }
    
    
    func getAllUsers(completion: @escaping ([UserProfile]) -> Void){
        print("called")
        var user = [UserProfile]()
        let allUsers = self.db.collection("Users")
            allUsers.getDocuments { snapshot, err in
            if err == nil && snapshot != nil {
                print("doc count: \(snapshot?.count)")
                for document in snapshot!.documents {
                    print("looping...")
                    let usersDocument = allUsers.document(document.documentID).collection("properties").document("properties").getDocument { document, err in
                        if err == nil && document != nil {
                            print("doc Found")
                        var result: UserProfile?
                            do {
                                result = try document?.data(as: UserProfile.self)
                                if let result = result {
                                user.append(result)
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
    }
    
    
    
}
