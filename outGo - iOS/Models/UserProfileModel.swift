//
//  UserProfileModel.swift
//  outGo - iOS
//
//  Created by Kaelin Iwugo on 7/12/21.
//

import Foundation

struct UserProfile: Codable {
    var userName: String
    var userID: String
    var group: Group
    var email: String
    var isFriend = Bool()
    
    enum CodingKeys: String, CodingKey {
        case userName = "userName"
        case userID = "userID"
        case group = "group"
        case email = "email"
    }
}



struct Group: Codable {
    var groupName: String
    var groupID: String
    
    enum CodingKeys: String, CodingKey {
        case groupName = "groupName"
        case groupID = "groupID"
    }
}

