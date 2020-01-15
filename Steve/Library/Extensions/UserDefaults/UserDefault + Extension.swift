//
//  UserDefault + Extension.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation

extension UserDefaults {
    
   public class func save(value: Any, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        UserDefaults.standard.synchronize()
    }
    
    class func saveModelToUserDefaults(obj: Any, key: String) {
        let userDefaults: UserDefaults = UserDefaults.standard
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: obj) as Data
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
    class func getModelFromUserDefaults(key: String) -> Any? {
        let userDefaults: UserDefaults = UserDefaults.standard
        var data: Data? = userDefaults.object(forKey: key) as? Data
        if data == nil {
            data = NSData() as Data
        }
        let objModel = NSKeyedUnarchiver.unarchiveObject(with: data!)
        return objModel
    }
    
    class func string(forKey: String) -> String {
        
        let stringValue = UserDefaults.standard.string(forKey: forKey)
        if stringValue == nil{
            return ""
        }
        return stringValue!
    }
    
    class func double(forKey: String) -> Double {
        let doubleValue = UserDefaults.standard.double(forKey: forKey)
        return doubleValue
    }
    
    class func bool(forKey: String) -> Bool {
        
        let boolValue = UserDefaults.standard.bool(forKey: forKey)
        return boolValue
    }
    
    class func array(forKey: String) -> NSArray {
        
        let array = UserDefaults.standard.array(forKey: forKey)
        if array == nil{
            return NSArray()
        }
        return array! as NSArray
    }
    
    class func dictionary(forKey: String) -> NSDictionary {
        
        let dictValue = UserDefaults.standard.dictionary(forKey: forKey)
        if dictValue == nil{
            return NSDictionary()
        }
        return dictValue! as NSDictionary
    }
}


extension UserDefaults {
    
    // MARK: - User Defaults
    /**
     sets/adds object to NSUserDefaults
     
     - parameter aObject: object to be stored
     - parameter defaultName: key for object
     */
    class func setObject(_ value: AnyObject?, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
        UserDefaults.standard.synchronize()
    }
    
    /**
     gives stored object in NSUserDefaults for a key
     
     - parameter defaultName: key for object
     
     - returns: stored object for key
     */
    class func objectForKey(_ defaultName: String) -> AnyObject? {
        return UserDefaults.standard.object(forKey: defaultName) as AnyObject?
    }
    
    /**
     removes object from NSUserDefault stored for a given key
     
     - parameter defaultName: key for object
     */
    class func removeObjectForKey(_ defaultName: String) {
        UserDefaults.standard.removeObject(forKey: defaultName)
        UserDefaults.standard.synchronize()
    }
}
