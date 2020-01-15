//
//  CreateProfile.swift
//  Steve
//
//  Created by Sudhir Kumar on 16/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

struct CreateProfile: Codable {
    var image:String?
    var gender:Int?
    var name:String?
    var age:Int?
    var phoneNumber:String?
    var qualification:String?
    var workExperience:String?
    var bio:String?
    var youtubeLink:String?
    var category:[Int]?
    var address:String?
    var radius:Int?
    var latitude:String?
    var longitude:String?
}

class CreateProfileRefresh {
    class func refresh() {
        profileList.name = nil
        profileList.age = nil
        profileList.phoneNumber = nil
        profileList.image = nil
        profileList.gender = nil
        profileList.qualification = nil
        profileList.workExperience = nil
        profileList.bio = nil
        profileList.youtubeLink = nil
        profileList.category = nil
        profileList.address = nil
        profileList.latitude = nil
        profileList.longitude = nil
        profileList.radius = nil
        //profileList.documentIds = nil
    }
}

