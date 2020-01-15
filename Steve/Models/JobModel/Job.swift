//
//  Job.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

struct Job: Codable {
    var id:Int?
    var userId:Int?
    var jobName:String?
    var description:String?
    var categoryId:Int?
    var wagePerHour:String?
    var jobStartTime:String?
    var jobEndTime:String?
    var duration:String?
    var address:String?
    var latitude:Double?
    var longitude:Double?
    var status:Int?
    var useName:String?
    var categoryName:String?
    var categoryImageUrl:String?
    var parentCategoryName:String?
    var parentCategoryId:Int?
    var distance:Double?
    var isApplied:Int?
    //var isConfirmedStatus:Int?
    var employerPhoneNumber:String?
    var employerAddress:String?
    var employerWebsite:String?
    //    var employerImageUrl:String?
    //    var employerAverageRating:Int?
    //    var employerYoutubeLink:String?
    //    var employerGender:Int?
    //    var employerEmail:String?
}
