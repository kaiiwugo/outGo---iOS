//
//  CustomAnnotations.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/7/21.
//

import Foundation
import UIKit
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var isPublic = Bool()
    var isActive = Bool()
    var pinID = String()
    var eventType = String()
    
    func setImage(eventType: String) -> UIImage{
        switch eventType {
        case "social":
            return UIImage(named: "RedPin")!
        case "community":
            return UIImage(named: "GreenPin")!
        case "active":
            return UIImage(named: "YellowPin")!
        case "featured":
            return UIImage(named: "BluePin")!
        default:
            return UIImage(named: "RedPin")!
        }
    }

}
