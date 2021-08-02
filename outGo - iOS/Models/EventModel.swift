//
//  EventModel.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/24/21.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import MapKit


struct Event: Codable {
    var properties: Properties
    var coordinates: Coordinates
    var current: Current
    var comments: [Comments]
    var visability: Visability
    
    enum CodingKeys: String, CodingKey {
        case properties = "properties"
        case coordinates = "coordinates"
        case current = "current"
        case comments = "comments"
        case visability = "visability"
    }
}

struct Properties: Codable {
    var host: String
    var eventDate: Date
    var details: String
    var postID: String
    var imageURL: String
    var eventType: String
    var eventImage = UIImage()
    var eventLocation = CLLocation()
    var eventLocation2d = CLLocationCoordinate2D()

    enum CodingKeys: String, CodingKey {
        case host = "host"
        case eventDate = "eventDate"
        case details = "details"
        case postID = "postID"
        case imageURL = "imageURL"
        case eventType = "eventType"
        }
}

struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
    enum CodingKeys: String, CodingKey {
        case latitude = "latitude"
        case longitude = "longitude"
    }
}

struct Current: Codable {
    var viewDistance: Double
    var isPublic: Bool
    var attendance: Int
    var distance: Double
    var isActive: Bool
    enum CodingKeys: String, CodingKey {
        case viewDistance = "viewDistance"
        case isPublic = "isPublic"
        case attendance = "attendance"
        case distance = "distance"
        case isActive = "isActive"
    }
}

struct Comments: Codable {
    var commentText: String
    var commentUser: String
    var commentTime: Date
    
    enum CodingKeys: String, CodingKey {
        case commentText = "commentText"
        case commentUser = "commentUser"
        case commentTime = "commentTime"
    }
}

struct Visability: Codable {
    var isPublic: Bool
    var groupEvent: Bool
    var friendEvent = Bool()
    
    enum CodingKeys: String, CodingKey {
        case isPublic = "isPublic"
        case groupEvent = "groupEvent"
    }
}


