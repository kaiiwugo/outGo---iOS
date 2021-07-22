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
    
}
