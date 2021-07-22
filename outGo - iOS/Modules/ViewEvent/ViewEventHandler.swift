//
//  ViewEventHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/2/21.
//

import Foundation
import FirebaseFirestore

class ViewEventHandler {
    static let shared = ViewEventHandler()
    let db = Firestore.firestore()
    enum Collection: String {
        case events = "All Events"
        case presets = "Preset Events"
            }
    
    func postComment(comment : Comments, collection: Collection, postID : String){
        let eventDocument = db.collection(collection.rawValue).document(postID)
        eventDocument.updateData([
            "comments": FieldValue.arrayUnion([["commentText": comment.commentText, "commentTime": comment.commentTime ,"commentUser": comment.commentUser]])
        ])
    }
    
    func addLike(postID : String, collection: Collection, completion: @escaping () -> Void){
        let eventDocument = db.collection(collection.rawValue).document(postID)
        eventDocument.getDocument { (document, error) in
            if let document = document, document.exists {
                var result: Event?
                do {
                    result = try document.data(as: Event.self)
                    let likes = result?.current.attendance
                    eventDocument.setData(["current": ["likes": likes! + 1]], merge: true)
                    completion()
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    func getAttendance(postID: String, collection: Collection, completion: @escaping (String, Int) -> Void){
        db.collection(collection.rawValue).document(postID).getDocument { (document, error) in
            if let document = document, document.exists {
                var result: Event?
                do {
                    result = try document.data(as: Event.self)
                    let attendance = result?.current.attendance
                    if let result = result {
                        var attendanceString = "0-10"
                        
                        if attendance! < 10 {
                            attendanceString = "a few outGo users"
                            completion(attendanceString, attendance!)
                        }
                        else if attendance! > 10 && attendance! < 15 {
                            attendanceString = "some outGo users"
                            completion(attendanceString, attendance!)
                        }
                        else if attendance! > 15 && attendance! < 20 {
                            attendanceString = "many outGo users"
                            completion(attendanceString, attendance!)
                        }
                        else {
                            attendanceString = "Trending"
                            completion(attendanceString, attendance!)
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
}


