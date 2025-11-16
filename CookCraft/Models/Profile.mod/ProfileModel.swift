//
//  ProfileModel.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 19/10/2025.
//

//struct Profile: Decodable {
//  let username: String?
//  let fullName: String?
//  let website: String?
//
//  enum CodingKeys: String, CodingKey {
//    case username
//    case fullName = "full_name"
//    case website
//  }
//}
//
//struct UpdateProfileParams: Encodable {
//  let username: String
//  let fullName: String
//  let website: String
//
//  enum CodingKeys: String, CodingKey {
//    case username
//    case fullName = "full_name"
//    case website
//  }
//}


import Foundation
import Supabase


//struct Profile: Codable, Equatable {
//    var id: UUID?
//    var is_suspended: Bool?
//    var email: String
//    var fullName: String
//    var avatarURL: String?
//    var gender: String?
//    var age: Int?
//    var bio: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case email
//        case fullName = "full_name"
//        case avatarURL = "avatar_url"
//        case gender, age, bio
//    }
//}
//
//struct UpdateProfileParams: Encodable {
//    var gender: String?
//    var age: Int?
//    var bio: String?
//    var avatar_url: String?
//}

struct Profile: Codable, Equatable {
    var id: UUID?
    var is_suspended: Bool?
    var email: String
    var fullName: String
    var avatarURL: String?
    var gender: String?
    var age: Int?
    var bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case is_suspended          // 👈 add this
        case email
        case fullName = "full_name"
        case avatarURL = "avatar_url"
        case gender, age, bio
    }
}


struct UpdateProfileParams: Encodable {
    var gender: String?
    var age: Int?
    var bio: String?
    var avatar_url: String?
}

