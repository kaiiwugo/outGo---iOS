//
//  MapPinHandler.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import Foundation
import UIKit
import Firebase

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
    
    
    
}

