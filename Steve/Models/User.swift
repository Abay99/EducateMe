//
//  User.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation


struct User : Codable
{
    // MARK: Properties
    var email: String?
    var id: Int?
    var facebookId: String?
    var name: String?
    var gender:Int?
    var isVerified: Int?
    var updatedAt: String?
    var userToken: String?
    var userType: Int?
    var image:String?
    var imageUrl:String?
    var phoneNumber : String?
    var averageRating : Float?
    var rating:Float?
    var isActive : Int?
    var isProfileComplete : Int?
    var address:String? //[UserAddressData]?
    var isFacebookUser : Int?
    var longitude:Double?
    var latitude:Double?
    var stripeCustomerId : String?
    var defaultRadius: Int?
    var qualification: String?
    var workExperience: String?
    var youtubeLink: String?
    var userCategories:[SelectedCategories]?
    var userWorkHistory:[WorkHistories]?
    var isAvailable: Int?
    
    // View profile
    var age:Int?
    var bio:String?
    var website:String?
    var accountNo:String?
    var accountTitle:String?
    var accRouting:String?
    var workHistoryMsg:String?
    var userDocuments:[Doc]?
}

struct UserFacebookData : Codable
{
    var accountID: String?
    var name: String?
    var email: String?
    var profilePicture: String?
    var fb_accessToken: String?
}

struct UserAddressData : Codable
{
    var id: Int?
    var userId: Int?
    var address:String?
    var latitude: Double?
    var longitude: Double?
    var isCurrent : Int?
}

struct SelectedCategories : Codable {
    var userId: Int?
    var category:String?
    var categoryId:Int?
    var parentCategoryName:String?
    var parentCategoryId:Int?
}

struct WorkHistories: Codable {
    var id: Int?
    var userId: Int?
    var employerName: String?
    var employerEmail: String?
    var status: Int?
}
