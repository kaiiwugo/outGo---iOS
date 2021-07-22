//
//  ExploreModel.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/27/21.
//

import Foundation
import UIKit

struct ExploreEventCell {
    let eventImage: UIImage
    let timeSincePost: String
    let distance: Double
    let eventType: String
    
    init(eventImage: UIImage, timeSincePost: String, distance: Double, eventType: String) {
        self.eventImage = eventImage
        self.timeSincePost = timeSincePost
        self.distance = distance
        self.eventType = eventType
    }
}
