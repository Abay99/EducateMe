//
//  APFacebookManager.swift
//  Steve
//
//  Created by Sudhir Kumar on 04/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import FBSDKCoreKit
//import FBSDKShareKit
import FBSDKLoginKit
import Social

// Completion Handler returns user or error
typealias FBCompletionHandler = (_ userDict: [String : String]?, _ error: NSError?) -> Void

class APFacebookManager {
    
    struct Keys {
        static let facebookAppId = kFacebookAppID
        static let FB_GRAPH_URL = "https://graph.facebook.com/"
        static let FB_GRAPH_API = FB_GRAPH_URL+"me"
    }
    
    fileprivate static var manager = APFacebookManager()
    //var facebookAppID: String?
    var configuration : FacebookConfiguration = FacebookConfiguration.defaultConfiguration()
    var fbCompletionHandler: FBCompletionHandler?
    
    var user : [String : String]? = [String : String]()
    
    
    // MARK: - Singleton Instance
    /**
     Initializes FacebookManager class to have a new instance of manager
     
     - parameter config: requires a FacebookConfiguration instance which is required to configure the manager
     
     - returns: an instance of FacebookManager which can be accessed via sharedManager()
     */
    class func managerWithConfiguration(_ config: FacebookConfiguration!) -> APFacebookManager {
        
        if config != nil {
            manager.configuration = config!
            manager.configuration.isConfigured = true
        }
        return manager
    }
    
    class func sharedManager() -> APFacebookManager {
        if isManagerConfigured() == false {
            _ = managerWithConfiguration(FacebookConfiguration.defaultConfiguration())
        }
        return manager
    }
    
    
    // MARK: - Helpers for Manager
    fileprivate class func isManagerConfigured() -> Bool {
        return self.manager.configuration.isConfigured
    }
    
    class func resetManager() {
        self.manager.configuration.isConfigured = false
    }
    
    
    // MARK: - Token
    class func token() -> FBSDKAccessToken? {
        return FBSDKAccessToken.current()
    }
    
    func tokenString() -> String {
        return FBSDKAccessToken.current().tokenString
    }
    
    func isTokenValid() -> Bool {
        if let _ = FBSDKAccessToken.current() {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: Profile
    func currentProfile() -> FBSDKProfile {
        return FBSDKProfile.current()
    }
    
    func logout() {
        
        FBSDKLoginManager().logOut()
        
        // flush permissions
        configuration.permissions = []
    }
    
    
    
    fileprivate func loginWithAccountFramework() {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook)
        
       let options = [ACFacebookAppIdKey:Keys.facebookAppId , ACFacebookPermissionsKey: ( [ FacebookConfiguration.Permissions.PublicProfile , FacebookConfiguration.Permissions.Email ] as AnyObject), ACFacebookAudienceKey: (ACFacebookAudienceFriends as AnyObject)] as [String : Any]
        
        accountStore.requestAccessToAccounts(with: accountType, options: options) { (success, error) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                if !success {
                    self.fbCompletionHandler!(nil, NSError(domain: "Error", code: 201, userInfo: ["info" : error?.localizedDescription ?? "Unable to login"]))
                    return
                }
                let accounts = accountStore.accounts(with: accountType) as! [ACAccount]
                guard let fbAccount = accounts.first else {
                    self.fbCompletionHandler!(nil, NSError(domain: "Error", code: 201, userInfo: ["info":"There is no Facebook account configured. You can add or create a Facebook account in Settings."]))
                    return
                }
                self.parseDetails(fbAccount: fbAccount)
            })
        }
    }
    
    
    func parseDetails(fbAccount:ACAccount){
    
        let dict=fbAccount.dictionaryWithValues(forKeys: ["properties"]) as NSDictionary
        let properties:NSDictionary=dict["properties"] as! NSDictionary
        
        self.fetchProfileInfoAccountsFramework(fbAccount, completion: { (success, id) in
            if success
            {
                properties.setValue(fbAccount.credential.oauthToken, forKey: "fb_accessToken")
                properties.setValue(id, forKey: "id")
                self.processAccountDetails(properties: properties)
            }
        })
    
    }
    
    func processAccountDetails(properties : NSDictionary){
        DispatchQueue.global().async (execute: {
            self.userParserForAccountsFramework(properties)
        })
    }
    
    fileprivate func loginWithFacebookSDK() {
        if self.isTokenValid() {
            self.fetchProfileInfo(nil)
        } else {
            //LogManager.logDebug("\(configuration.permissions!)")
            
            FBSDKLoginManager().loginBehavior = .native
            
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile" , "email"], from: nil) { (result, error) -> Void in
                if error != nil || (result?.isCancelled)! {
                    // According to Facebook:
                    // Errors will rarely occur in the typical login flow because the login dialog
                    // presented by Facebook via single sign on will guide the users to resolve any errors.
                    
                    // Process error
                    FBSDKLoginManager().logOut()
                    self.fbCompletionHandler!(nil, error as NSError?)
                    
                }else {
                    // If you ask for multiple permissions at once, you
                    // should check if specific permissions missing
                    self.fetchProfileInfo(nil)
                }
            }
        }
    }
    
    //
    // MARK: - Login
    //
    
    /**
     Login with facebook which returns dictionary with format {"email" : "" , "accountID" : "" , "name" : "" , "profilePicture" : "" , "fb_accessToken" : ""}
     
     - parameter handler: return with SocialCompletionHandler, either valid social user or with error information
     */
    
    func login(_ handler: @escaping FBCompletionHandler) {
        
        self.fbCompletionHandler = handler
        
        loginWithFacebookSDK()
    }
    
    //
    // MARK: - Profile Info
    //
    
    /**
     Returns user facebook profile information
     
     - parameter completion: gets callback once facebook server gives response
     */
    func fetchProfileInfo(_ completion: FBCompletionHandler?) {
        // See link for more fields:
        // http://stackoverflow.com/questions/32031677/facebook-graph-api-get-request-should-contain-fields-parameter-swift-faceb
        
        if completion != nil {
            self.fbCompletionHandler = completion
        }
        
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, first_name, last_name, gender, picture.width(400).height(400)"], httpMethod: "GET")
        request.start { (connection, result, error) -> Void in
            
            guard let error = error else {
                if let userInfo:NSDictionary = result as? NSDictionary {
                    
                    self.userParser(userInfo)
                    
                } else {
                    self.fbCompletionHandler!(nil, NSError(domain: "Error", code: 201, userInfo: ["info":"Invalid data received"]))
                }
                return
            }
            self.logout()
            self.fbCompletionHandler!(nil, NSError(domain: "Error", code: 201, userInfo: ["info" : error.localizedDescription]))

        }
    }
    
    func fetchProfileInfoAccountsFramework(_ fbAccount : ACAccount , completion : @escaping (_ success:Bool , _ id : String) -> Void) {
        let url = URL.init(string: Keys.FB_GRAPH_API)
        let request = SLRequest.init(forServiceType: SLServiceTypeFacebook, requestMethod: SLRequestMethod.GET, url: url, parameters: nil)
        request?.account = fbAccount
        request?.perform { (data, respomse, error) in
            do {
                let responseDict = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                completion(true, responseDict.value(forKey: "id") as! String)
                
            }catch  {
                
                completion(false, "")
                return
            }
        }
    }
    
    func userParser(_ userDict : NSDictionary) {
        
        self.user?["email"] = userDict["email"] as? String
        self.user?["accountID"] = userDict["id"] as? String
        self.user?["name"] = (userDict["first_name"] as? String)! + " " + (userDict["last_name"] as? String)!
        
        
        let picture = userDict["picture"] as! NSDictionary
        let data = picture["data"] as! NSDictionary
        self.user?["profilePicture"] = data["url"] as? String
        
        self.user?["fb_accessToken"] = (APFacebookManager.token()?.tokenString)!
        self.fbCompletionHandler!(self.user , nil)
    }
    
    func userParserForAccountsFramework(_ userDict : NSDictionary) {
        
        self.user?["email"] = userDict["ACUIDisplayUsername"] as? String
        self.user?["accountID"] = userDict["id"] as? String//String(userDict["uid"] as! Int)
        self.user?["name"] = userDict["ACPropertyFullName"] as? String
        self.user?["profilePicture"] = "\(Keys.FB_GRAPH_URL)\(String(userDict["uid"] as! Int))/picture?type=large"
        self.user?["fb_accessToken"] = userDict["fb_accessToken"] as? String
        self.fbCompletionHandler!(self.user , nil)
    }
    
    
    //
    // MARK: - Friends
    //
    
    /**
     Returns user's facebook friends who are using current application
     
     - parameter completion: gets callback once facebook server gives response
     */
    func findFriends(_ completion: @escaping (_ result: NSDictionary?, _ error: NSError?) -> Void) {
        
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "id, email, name, first_name, last_name, gender, picture"], httpMethod: "GET")
        request.start { (connection, result, error) -> Void in
            
            guard let error = error else {
                if let friends:NSDictionary = result as? NSDictionary {
                    completion(friends, nil)
                } else {
                    completion(nil, NSError(domain: "Error", code: 201, userInfo: ["info":"Invalid data received"]))
                }
                return
            }
            self.logout()
            completion(nil, NSError(domain: "Error", code: 201, userInfo: ["info" : error.localizedDescription]))

        }
    }
    
    //
    // MARK: - Share link content
    //
    
    /**
     Post a Link with image having a caption, description and name
     * Link with image is posted on the me/feed graph path
     * link : NSURL - link to be shared with post
     * picture : NSURL - picture to be shred with post
     * name : NSString - Name for post( appears like a title)
     * description : NSString - Description for post ( appears like a subtitle)
     * caption : NSString - caption for image (apeears at bottom)
     * competion : gets callback once facebook server gives response
     */
    func shareLinkContent(_ link: URL, picture: URL, name: String, description: NSString, caption: NSString, completion: @escaping (_ result: NSDictionary?, _ error: NSError?) -> Void) {
        
        let  params =  ["" : "null",
                        "link" : link.absoluteString,
                        "picture" : picture.absoluteString,
                        "name" : name,
                        "description": description,
                        "caption": caption] as [String : Any]
        
        let request = FBSDKGraphRequest(graphPath:"me/feed", parameters:params, httpMethod:"POST")
        
        _ = request?.start{(connection,result,error)->Void in
            guard let error = error else {
                if let id:NSDictionary = result as? NSDictionary {
                    completion(id, nil)
                } else {
                    completion(nil, NSError(domain: "Error", code: 201, userInfo: ["info":"Invalid data received"]))
                }
                return
            }
            completion(nil, NSError(domain: "Error", code: 201, userInfo: ["info" : error.localizedDescription]))

        }
    }
    
}



// MARK: - Facebook Configutaion Class

class FacebookConfiguration {
    
    fileprivate static var fbConfiguration: FacebookConfiguration?
    
    var isConfigured: Bool! = false
    var permissions: [String]!
    var facebookAppID : String = kFacebookAppID
    
    // MARK: - Permissions
    struct Permissions {
        static let PublicProfile = "public_profile"
        static let Email = "email"
        static let UserFriends = "user_friends"
        static let UserAboutMe = "user_about_me"
        static let UserBirthday = "user_birthday"
        static let UserHometown = "user_hometown"
        static let UserLikes = "user_likes"
        static let UserInterests = "user_interests"
        static let UserPhotos = "user_photos"
        static let FriendsPhotos = "friends_photos"
        static let FriendsHometown = "friends_hometown"
        static let FriendsLocation = "friends_location"
        static let FriendsEducationHistory = "friends_education_history"
    }
    
    init(scope: [String]) {
        permissions = scope
    }
    
    class func customConfiguration(_ customPermissions : [String]) -> FacebookConfiguration {
        
        if fbConfiguration == nil {
            fbConfiguration = FacebookConfiguration(scope: customPermissions)
        }
        return fbConfiguration!
    }
    
    class func defaultConfiguration() -> FacebookConfiguration {
        
        if fbConfiguration == nil {
            fbConfiguration = FacebookConfiguration(scope: defaultPermissions())
        }
        
        // Optionally add to ensure your credentials are valid:
        FBSDKLoginManager.renewSystemCredentials { (result, error) -> Void in
            if let _ = error {
                //LogManager.logError(error.localizedDescription)
            }
        }

        
        return fbConfiguration!
    }
    
    // MARK: - Helpers
    fileprivate class func fbAppId() -> String! {
        return FacebookConfiguration.fbConfiguration?.facebookAppID
    }
    
    fileprivate class func defaultPermissions() -> [String] {
        return [Permissions.PublicProfile, Permissions.Email]
    }
    
    
}
