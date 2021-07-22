//
//  Utilities.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 6/27/21.
//

import Foundation
import CoreLocation

class Utilities {
    enum AddressFormat: String {
        case long = "long"
        case standard = "standard"
        case short = "short"
            }
    
    static let shared = Utilities()
    
    func getTimePassed(postDate: NSDate) -> String {
        let secondsAgo = round(Date().timeIntervalSince(postDate as Date))
        let timeAgo: String
        
        if secondsAgo < 120 && secondsAgo > 0 {
            timeAgo = "1m"
        }
        else if secondsAgo >= 120 && secondsAgo < 3600 {
            let mins = Int(round(secondsAgo/60))
            timeAgo = "\(mins)m"
        }
        else if secondsAgo >= 3600 && secondsAgo < 86400 {
            let hours = Int(round(secondsAgo/3600))
            timeAgo = "\(hours)h"
        }
        else if secondsAgo > 86400 {
            let days = Int(round(secondsAgo/86400))
            timeAgo = "\(days)d"
        }
        //Future Events
        else if secondsAgo < 0 && secondsAgo > -3600 {
            let mins = Int(round(secondsAgo/60))
            timeAgo = "+\(mins)m"
        }
        else if secondsAgo <= -3600 && secondsAgo > -86400 {
            let hours = Int(round(secondsAgo/(-3600)))
            timeAgo = "+\(hours)h"
        }
        else {
            let days = Int(round(secondsAgo/(-86400)))
            timeAgo = "+\(days)d"
        }
        return timeAgo
    }
    
    func getAddress(Address : AddressFormat, location : CLLocation, completion: @escaping(String) -> Void) throws {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            var addressString = String()
            completion("")
            switch Address {
            case .long: //Location Name+Address, City, State,
                addressString = "\(placeMark.name!), \(placeMark.locality!), \(placeMark.administrativeArea!)"
                completion(addressString)
                break
            case .standard: //Location Name+Address, City
                addressString = "\(placeMark.name!), \(placeMark.locality!)"
                completion(addressString)
                break
            case.short: //City
                addressString = "\(placeMark.locality!)"
                completion(addressString)
                break
            }
        })
    }
}
