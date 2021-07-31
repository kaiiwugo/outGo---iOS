//
//  UserModel.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import Foundation
import UIKit

struct UserSearchModel {
    let profilePicture: UIImage
    let userName: String
    let currentAction: String
    let isFriend: Bool
    
    init(profilePicture: UIImage, userName: String, currentAction: String, isFriend: Bool) {
        self.profilePicture = profilePicture
        self.userName = userName
        self.currentAction = currentAction
        self.isFriend = isFriend
    }
}
