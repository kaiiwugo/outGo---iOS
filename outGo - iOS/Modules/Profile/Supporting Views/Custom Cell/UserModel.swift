//
//  UserModel.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import Foundation
import UIKit

struct UserModel {
    let profilePicture: UIImage
    let userName: String
    let currentAction: String
    
    init(profilePicture: UIImage, userName: String, currentAction: String) {
        self.profilePicture = profilePicture
        self.userName = userName
        self.currentAction = currentAction
    }
}
