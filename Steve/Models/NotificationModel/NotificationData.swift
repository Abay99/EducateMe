//
//  NotificationData.swift
//  Steve
//
//  Created by Sudhir Kumar on 21/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

struct NotificationData: Codable {
    var id:Int?
    var jobId:Int?
    var senderId:Int?
    var recipientId:Int?
    var type:Int?
    var text:String?
    var isRead:Int?
    var createdAt:String?
    var updatedAt:String?
}
