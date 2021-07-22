//
//  AdminAddPresets.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/14/21.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class AdminAddPresets {
    static let shared = AdminAddPresets()
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    var imageData = Data()
    let eventDetails = "Night Club"
    let eventDate = Date()
    let location = ""
    let eventType = "social"
    let lat = 39.955158
    let long = -75.199948
    let host = "West And Down"
    var imageURL = ""
    var isActive = true
    
    func addEvent(){
        DispatchQueue.main.async {
            //CreateHandler.shared.getImageURL(imageData: self.imageData ?? Data(), date: self.eventDate) { result in
                let eventDocument = self.db.collection("Preset Events").document()
                eventDocument.setData(["comments": [], "coordinates": ["latitude": self.lat, "longitude": self.long], "properties": ["details": self.eventDetails, "host": self.host, "imageURL": "", "eventDate": self.eventDate, "postID": eventDocument.documentID, "eventType": self.eventType], "current": ["distance": 0, "isPublic": true, "likes": 0, "viewDistance": 0, "isActive": self.isActive]])
           // }
        }
    }
}
