//
//  UserManager.swift
//  Steve
//
//  Created by Sudhir Kumar on 23/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

/// User Manager - manages all feature for User model
class UserManager: NSObject {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let activeUser = "activeUser"
        static let accessToken = "accessToken"
        static let userEmail = "userEmail"
        static let userDocuments = "userDocuments"
        static let userRegistredEmail = "userRegistredEmail"
        static let docEditingStatus = "docEditingStatus"

    }

    var accessToken: String? {
        get {
            return UserDefaults.objectForKey(SerializationKeys.accessToken) as? String
        }
        set {
            UserDefaults.setObject(newValue as AnyObject, forKey: SerializationKeys.accessToken)
        }
    }
    
    

    fileprivate var _activeUser: User?

    var activeUser: User! {
        get {
            return _activeUser
        }
        set {
            _activeUser = newValue

            if let _ = _activeUser {
                saveActiveUser()
            }
        }
    }

    // MARK: - Singleton Instance
    class var shared: UserManager {
        struct Singleton {
            static let instance = UserManager()
        }
        return Singleton.instance
    }

    fileprivate override init() {
        // initiate any queues / arrays / filepaths etc
        super.init()

        // Load last logged user data if exists
        if isLoggedInUser() {
            loadActiveUser()
        }
    }

    func isLoggedInUser() -> Bool {

        guard let _ = UserDefaults.objectForKey(SerializationKeys.activeUser)
        else {
            return false
        }
        return true
    }
    
 
    
    func setUserCurrentLocation(){
//        if let userAddressArr = self.activeUser.address{
//            for userAddressData in userAddressArr{
//                //if userAddressData.isCurrent == 1 {
//                    self.activeUser.latitude = userAddressData.latitude
//                    self.activeUser.longitude = userAddressData.longitude
//                //}
//            }
//        }
    }
    
    
    func checkIfAddressAlreadySelected(address : String) -> Bool{
//        if let userAddressArr = self.activeUser.address{
//            for userAddress in userAddressArr{
//                if(userAddress.address == address){
//                    return true
//                }
//            }
//        }
        return false
    }
    
    // MARK: - KeyChain / User Defaults / Flat file / XML

    /**
     Load last logged user data, if any
     */
    func loadActiveUser() {
        var user:User?
        guard let decodedUser = UserDefaults.objectForKey(SerializationKeys.activeUser) as? Data else {
            return }
        guard let data = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as? Data else { return }
        do {
            user = try PropertyListDecoder().decode(User.self, from: data)
        } catch {
            return
        }
        self.activeUser = user
    }

    func lastLoggedUserEmail() -> String? {
        return UserDefaults.objectForKey(SerializationKeys.userEmail) as? String
    }

    /**
     Save current user data
     */
    func saveActiveUser() {
        do {
            let data = try PropertyListEncoder().encode(self.activeUser)
            UserDefaults.setObject(NSKeyedArchiver.archivedData(withRootObject: data) as AnyObject, forKey: SerializationKeys.activeUser)

            if let email = self.activeUser.email {
                UserDefaults.setObject(email as AnyObject?, forKey: SerializationKeys.userEmail)
            }
        } catch {
        }
    }

    /**
     Delete current user data
     */
    func deleteActiveUser() {
        // remove active user from storage
        UserDefaults.removeObjectForKey(SerializationKeys.activeUser)
        // free user object memory
        self.activeUser = nil
    }
    
    func saveUserUploadedDoc(docs:[[String:String]]){
        UserDefaults.standard.set(docs as AnyObject, forKey: SerializationKeys.userDocuments)
    }
    
    func getUserUploadedDoc() -> [[String:String]]?  {
        
       if let result = UserDefaults.standard.value(forKey: SerializationKeys.userDocuments) as? [[String:String]] {
            return result
        }
       else {return nil}
    }
    
    func deleteUserUploadedDocFromLocal() {
        UserDefaults.standard.set(nil, forKey: SerializationKeys.userDocuments)
    }
    
    func saveDocEditingStatus()  {
        UserDefaults.standard.set(true, forKey: SerializationKeys.docEditingStatus)
    }
    
    func getDocEditingStatus() -> Bool {
       return UserDefaults.standard.bool(forKey: SerializationKeys.docEditingStatus)
    }
    
    func clearSaveDocEditing() {
        UserDefaults.standard.removeObject(forKey: SerializationKeys.docEditingStatus)
    }
    
    func saveRegisteredEmail(emailId:String)  {
        UserDefaults.standard.set(emailId as AnyObject, forKey: SerializationKeys.userRegistredEmail)
    }
    
    func getRegisteredEmail() -> String? {
        if let result = UserDefaults.standard.value(forKey: SerializationKeys.userRegistredEmail) as? String {
            return result
        }
        else {return nil}
    }
}
