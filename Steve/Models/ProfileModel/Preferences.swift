//
//  Preferences.swift
//  Steve
//
//  Created by Sudhir Kumar on 16/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

struct Preferences: Codable {
    //var categories:[CategoryList]?
    var id:Int?
    var name:String?
    var image:String?
    var parentId:Int?
    var subCategories:[JobCategories]?
    
    //self variable
    var isCategorySelected:Bool?
}

struct JobCategories: Codable {
    var id:Int?
    var name:String?
    var parentId:Int?
    
    //self variable
    var isJobSelected:Bool?
}
