//
//  CoreLocationManager.swift

import UIKit
import CoreLocation
import GoogleMaps

@objc protocol LocationManagerDelegate{
    @objc optional func locationManagerUserCurrentLocation(location:CLLocation)
    @objc optional func locationManagerUserCurrentLocationAndAddress(location:CLLocation,address:String)
    @objc optional func locationManagerFailedToGetLocation(error:Error)
    @objc optional func locationServiceDisabled()
    @objc optional func deviceLocationDisabled()
}


class CoreLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = CoreLocationManager()
    var delegate: LocationManagerDelegate?
    var locationManager: CLLocationManager?
    var currentLocation : CLLocation?
    var currentAddress : String?
    
    typealias addressCompletion = (String?, String?, GMSAddress?) -> Void
    
    
    func canUseLocation() -> Bool {
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        return locationServicesEnabled && (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.notDetermined && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.restricted)
    }
    
    func locationHasBeenAsked() -> Bool{
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined{
            return false
        }else{
            return true
        }
    }
    
    func locationServicesEnabled() -> Bool{
        if CLLocationManager.locationServicesEnabled(){
            return true
        }else{
            return false
        }
    }
    
    
    func askPermissionAndStartLocationUpdate() {
        
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.distanceFilter = 0
            self.locationManager!.delegate = self;
        }
        if CLLocationManager.locationServicesEnabled() {
            
//            if #available(iOS 11.0, *) {
//                self.locationManager?.requestAlwaysAuthorization();
//            }
//            else {
//                self.locationManager?.requestWhenInUseAuthorization()
//            }
            
            
            if (self.locationManager?.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)))!{
                self.locationManager?.requestWhenInUseAuthorization()
                LogManager.logMessage(mesage:"Location Permission Asked))")
            }
            else
            {
                self.delegate?.locationServiceDisabled!()
            }
        } else {
            self.delegate?.deviceLocationDisabled!()
        }
    }
    
    
    func startLocationUpdating()
    {
        
        LogManager.logMessage(mesage:"Start updating Location))")

        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self;
        }
        if self.canUseLocation() {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self;
            self.locationManager?.startUpdatingLocation()
//            self.locationManager?.requestLocation()
        }
        else{
            self.delegate?.locationServiceDisabled!()
        }
    }
    // MARK: - Location Manager Delegate Method
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        LogManager.logMessage(mesage:"inside didChangeAuthorization )")

        if status == CLAuthorizationStatus.denied {
            // The user denied authorization
            self.delegate?.locationServiceDisabled!()
            LogManager.logMessage(mesage:"inside denied )")

            if locationServicesEnabled(){
                
            }
        } else if status == CLAuthorizationStatus.authorizedWhenInUse {
            // The user accepted authorization Get Location
            self.locationManager?.startUpdatingLocation()
            LogManager.logMessage(mesage:"inside authorizedWhenInUse and start Updating Location )")

            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLoc = locations.last
        LogManager.logMessage(mesage:"did update Location delegate))")
        if currentLoc != nil {
            currentLocation = currentLoc
            self.locationManager?.stopUpdatingLocation()
            self.locationManager?.delegate = nil
            self.locationManager = nil
            LogManager.logMessage(mesage:" Going to fetch current Address Location))")
            
            self.getAddressFromLocation(CLLocation(latitude: (currentLocation?.coordinate.latitude) ?? 0.0, longitude: (currentLocation?.coordinate.longitude) ?? 0.0)) { strAddress, strFullAddress, _ in
                if (strFullAddress != nil){
                    self.currentAddress = strFullAddress
                    LogManager.logMessage(mesage:" inside current Address Location))")

                    if let _ = self.currentLocation {
                    self.delegate?.locationManagerUserCurrentLocationAndAddress!(location: self.currentLocation!, address: self.currentAddress ?? "")
                    }
                }
                else{
                  //  self.delegate?.locationManagerFailedToGetLocation!(error: nil)
                }
            }
            self.fetchAddress(location: currentLocation!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.locationManagerFailedToGetLocation!(error: error)
    }
    
    // Get Address From Location Coordinates
    func fetchAddress(location : CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            if error != nil {
                self.currentAddress = ""
                self.delegate?.locationManagerFailedToGetLocation!(error: error!)
                return
            }
            if (placemarks?.count)! > 0 {
                if let placemark = (placemarks?[0])  {
                self.currentAddress = self.fetchAddressStringFrom(placemark: placemark)
                self.delegate?.locationManagerUserCurrentLocationAndAddress!(location: location, address: self.currentAddress!)
                }
            }
            else{
                self.delegate?.locationManagerUserCurrentLocationAndAddress!(location: location, address: "")
               self.currentAddress = ""
            }
        }
    }
    
    func fetchAddressStringFrom(placemark:CLPlacemark)-> String{
        var addressString : String = ""
        if placemark.subThoroughfare != nil {
            addressString = placemark.subThoroughfare! + ", "
        }
        if placemark.thoroughfare != nil {
            addressString = addressString + placemark.thoroughfare! + ", "
        }
        if placemark.subLocality != nil {
            addressString = addressString + placemark.subLocality! + ", "
        }
        if placemark.locality != nil {
            addressString = addressString + placemark.locality! + ", "
        }
        if placemark.subAdministrativeArea != nil {
            addressString = addressString + placemark.subAdministrativeArea! + ", "
        }
        if placemark.administrativeArea != nil {
            addressString = addressString + placemark.administrativeArea! + ", "
        }
        if placemark.postalCode != nil {
            addressString = addressString + placemark.postalCode! + ", "
        }
        if placemark.country != nil {
            addressString = addressString + placemark.country! + ","
        }
        if addressString.count > 1{
            addressString.removeLast()
        }
        return addressString
    }
    
    // Get Location Coordinated From Address String
    func convertAddressToCoordinates(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
            if error != nil {
                self.delegate?.locationManagerFailedToGetLocation!(error: error!)
                return
            }
            else{
                if (placemarks?.count)! > 0{
                    self.currentLocation = placemarks?[0].location
                    self.delegate?.locationManagerUserCurrentLocation!(location: self.currentLocation!)
                }
                else{
                    self.delegate?.locationManagerFailedToGetLocation!(error: error!)
                }
            }
        })
    }
    
    func distanceFromLocation(locationDict : Dictionary<String, Any>) -> Double
    {
        if currentLocation != nil {
            let barLocation : CLLocation = CLLocation(latitude: locationDict["lat"] as! CLLocationDegrees, longitude: locationDict["lng"] as! CLLocationDegrees)
            let meters : CLLocationDistance = (currentLocation?.distance(from: barLocation))!
            return meters
        }
        return 0.0

    }
    
    
    // Google Geocoding and reverse geocoding mthods
    
    
    
    
    
    
    
    
    
    
    // MARK: Reverse Geocoding
    func getAddressFromLocationOld(_ location: CLLocation , complationBlock: @escaping addressCompletion) {
        var strAddress: String = ""
        var strFullAddress: String? = ""
        LogManager.logMessage(mesage:" Address Requested for Location))")
        
      
        
        let loactionProvided: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        LogManager.logMessage(mesage:" gmsGeocode going to initiate))")
        
//        guard let _ = loactionProvided else {
//            // Value requirements not met, do something
//            complationBlock("Unknown Location", "Unknown Location", nil)
//            return
//        }

        let geoCoderInstance: GMSGeocoder = GMSGeocoder()
        LogManager.logMessage(mesage:" gmsGeocode goint to initiated))")

        geoCoderInstance.reverseGeocodeCoordinate(loactionProvided) { (response, _) -> Void in
            LogManager.logMessage(mesage:" Received reverseGeocodeCoordinate))")
            if response == nil {
                LogManager.logMessage(mesage:" Received Unkown from Location))")
                complationBlock("Unknown Location", "Unknown Location", nil)
                return
            }
             LogManager.logMessage(mesage:" Received Address from Location))")
            
            guard let _ = response?.firstResult() else {
                // Value requirements not met, do something
                return
            }

            
            let result: GMSAddress = response!.firstResult()!
            let arrLines: NSArray = result.lines! as NSArray
            strFullAddress = ""
            
            if result.thoroughfare != nil {
                strFullAddress = result.thoroughfare! + ", "
            }
            if result.subLocality != nil {
                strFullAddress = strFullAddress! + result.subLocality! + ", "
            }
            if result.locality != nil {
                strFullAddress = strFullAddress! + result.locality! + ", "
            }
            if result.administrativeArea != nil {
                strFullAddress = strFullAddress! + result.administrativeArea! + ", "
            }
            if result.postalCode != nil {
                strFullAddress = strFullAddress! + result.postalCode! + ", "
            }
            if result.country != nil {
                strFullAddress = strFullAddress! + result.country! + ","
            }
            if strFullAddress!.count > 1{
                strFullAddress!.removeLast()
            }
            
            strAddress = arrLines.firstObject as! String
            if strAddress.isEmpty {
                strAddress = arrLines.lastObject as! String
            }
            complationBlock(strAddress, strFullAddress, result)
        }
    }
    
    
    func getAddressFromLocation(_ location: CLLocation , complationBlock: @escaping addressCompletion) {
       
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()

        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = location.coordinate.latitude
        center.longitude = location.coordinate.longitude
        
        
        ceo.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                     complationBlock("Unknown Location", "Unknown Location", nil)
                }
                if let pm = placemarks as? [CLPlacemark] {
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                   
                    var strFullAddress : String = ""
                    if pm.subLocality != nil {
                        strFullAddress = strFullAddress + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        strFullAddress = strFullAddress + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        strFullAddress = strFullAddress + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        strFullAddress = strFullAddress + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        strFullAddress = strFullAddress + pm.postalCode! + " "
                    }
                    
                    complationBlock(strFullAddress, strFullAddress, nil)
                }
                }
        })
        
    }

}
