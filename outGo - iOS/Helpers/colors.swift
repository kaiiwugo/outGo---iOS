//
//  colors.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/10/21.
//

import Foundation
import UIKit


class colors {
    enum Color: String {
        case primary = "primary"
        case secondary = "secondary"
            }
    
    static func getColor(color: Color) -> UIColor {
        
        let primary = UIColor.init(red: 239/255, green: 62/255, blue: 62/255, alpha: 1)
        let secondary = UIColor.init(red: 255/255, green: 214/255, blue: 0/255, alpha: 1)
        
        switch color {
        case .primary:
            return primary
        case .secondary:
            return secondary
        }
    }
}
