//
//  Message.swift
//  Steve
//
//  Created by Sudhir Kumar on 18/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

//struct Notifications: Codable {
//    var alert: [String:String]?
//    var data:NotifData?
//    var badge: Int?
//}

struct Notifications: Codable {
    var type: Int?
    var id: Int?
    var jobId: Int?
}
