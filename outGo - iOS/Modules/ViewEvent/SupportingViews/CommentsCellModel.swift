//
//  CommentsCellModel.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/2/21.
//

import Foundation
import UIKit

struct CommentCell {
    
    let profilePicture: UIImage
    let profileName: String
    let comment: String
    
    init(profilePicture: UIImage, profileName: String, comment: String) {
        self.profilePicture = profilePicture
        self.profileName = profileName
        self.comment = comment
    }
}

struct CommentInfo: Codable {
    var commentText: String
    var commentUser: String
    var commentTime: Date
    
    enum CodingKeys: String, CodingKey {
        case commentText = "commentText"
        case commentUser = "commentUser"
        case commentTime = "commentTime"
    }
    
}
