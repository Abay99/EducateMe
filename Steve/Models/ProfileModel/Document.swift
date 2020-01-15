//
//  Document.swift
//  Steve
//
//  Created by Rishi Kumar on 22/10/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
typealias docCompletionHandler = (_ status:Bool, _ doc:Document?, _ error:Error?) -> Void
class Document: Codable {
    var id : Int?
    var documentName : String?
    var createdAt : String?
    var mediaType:Int?
    var imageData:Data?
    var resourceId:String?
    var image:String?
    var imageUrl:String?
    var docType:String?
    var isUploadingProgress:Bool?
}

struct Doc: Codable {
    var id : Int?
    var documentName : String?
    var createdAt : String?
    var mediaType:Int?
    var imageData:Data?
    var resourceId:String?
    var image:String?
    var imageUrl:String?
    var docType:Int?
}

extension Document {
    func uploadDoc(image:UIImage , completion:@escaping docCompletionHandler) {
        self.isUploadingProgress = true

        var fileParams:[String:AnyObject] = [String:AnyObject]()
        //if let data:Data = UIImagePNGRepresentation(image) {
        if let data:Data = UIImageJPEGRepresentation(image, 0.5){
            fileParams[MultiPartKey.kFileNameKey] = kRequestImageName as AnyObject?
            fileParams[MultiPartKey.kSourceKey] = "imageUrl" as AnyObject?
            fileParams[MultiPartKey.kValueKey] = data as AnyObject
            fileParams[MultiPartKey.kContentTypeKey] = kContentImageType as AnyObject?
        }
        var dataFiled = [String:String]()
        let id = String.init(self.id ?? 0)
        dataFiled.updateValue(id, forKey: "docType")
        uploadDocToServer(fileParams: fileParams, dataField: dataFiled as [String : String], completion)
    }
    
    func uploadPDFDoc(data:Data , completion:@escaping docCompletionHandler) {
         self.isUploadingProgress = true
        var fileParams:[String:AnyObject] = [String:AnyObject]()
        fileParams[MultiPartKey.kFileNameKey] = kRequestPDFName as AnyObject?
        fileParams[MultiPartKey.kSourceKey] = "imageUrl" as AnyObject?
        fileParams[MultiPartKey.kValueKey] = data as AnyObject
        fileParams[MultiPartKey.kContentTypeKey] = kContentPDFType as AnyObject?
        fileParams[MultiPartKey.kmimeTypeKey] = kContentPDFType as AnyObject?
        var dataFiled = [String:String]()
        let id = String.init(self.id ?? 0)
        dataFiled.updateValue(id, forKey: "docType")
        uploadDocToServer(fileParams: fileParams, dataField: dataFiled, completion)
    }
    
    func uploadDocToServer(fileParams:[String:AnyObject] , dataField:[String:String] , _ completion:@escaping (docCompletionHandler)) {
        
        DataManager.shared.uploadUserDocWithUploadTask(fileParams, dataField: dataField, completion: {  (success, error, obj) -> (Void) in
            self.isUploadingProgress = false
            if success == true {
                self.image = obj?.image;
                self.resourceId = obj?.resourceId;
                self.docType = obj?.docType;
                self.imageUrl = obj?.imageUrl;
                completion(true,obj,nil);
            }
            else {
                completion(false,nil,error)
                TopMessage.shared.showMessageWithText(text: error?.localizedDescription ?? "", completion: nil)
            }
        })
    }
}
