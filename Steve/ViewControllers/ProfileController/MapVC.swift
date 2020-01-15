//
//  MapVC.swift
//  Steve
//
//  Created by Sudhir Kumar on 24/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import Analytics

protocol MapVCDelegate: class  {
    func didLocationSave(lat:Double?, lng:Double?, address:String?)
}

class MapVC: UIViewController {

    // IBOutlets
    @IBOutlet weak var topView: TopBarView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var markerView:UIImageView!
    @IBOutlet weak var overlayView: UIView!
    
    
    // Variables
    var lat:Double = 0.0
    var lng:Double = 0.0
    var zoomLevel:Float = 15.0
    var locationManager = CoreLocationManager.sharedInstance
    var userAddress:String = ""
    var isMarkerAdded = false
    var radius:Int = 1
    
    // Variables For Search Places
    var isPlacesShow:Bool = false
    var placeView:PlaceView?
    var placeClient = GMSPlacesClient()
    var arrSuggestedSource = NSMutableArray()
    weak var delegate:MapVCDelegate?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        SEGAnalytics.shared().track(Analytics.loadedAPpage)
//        SEGAnalytics.shared().track(Analytics.loadedAscreen)
        
        SEGAnalytics.shared().screen(AnalyticsScreens.MapVC)
        addressTextField.clearButtonMode = .whileEditing;
        NotificationCenter.default.addObserver(self, selector: #selector(getUserCurrentLocation), name: NSNotification.Name(rawValue: NotificationName.moveNext.value), object: nil)
        self.setupHeader()
        self.setupUI()
        self.setupData()
        LogManager.logMessage(mesage:"Map VC view did load ))")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Methods
    private func setupHeader() {
        self.topView.setHeaderData(title: "Location", leftButtonImage: AppImage.backButton)
        self.topView.delegate = self
    }
    
    private func setupUI() {
        self.mapView.delegate = self
        self.mapView.setMapStyle()
        self.appendOverlayCircle()
    }
    
    private func setupData() {
        if self.lat == 0.0 || self.lng == 0.0 {
            self.getUserCurrentLocation()
        } else {
            self.addMapView()
        }
    }
    
    private func addMapView() {
        if self.lat != 0.0 || self.lng != 0.0 {
            self.showOverlayView()
        } else {
            self.hideOverlayView()
        }
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: self.lat, longitude: self.lng, zoom: self.zoomLevel)
        mapView.clear()
        //mapView.camera = camera
        mapView.animate(to: camera)
        self.showMarker()
    }
    
    private func drawCircle(position: CLLocationCoordinate2D) {
        let circle = GMSCircle(position: position, radius: CLLocationDistance(self.radius * 1000))
        circle.map = mapView
        circle.strokeColor = .white
        circle.fillColor = .clear
        circle.strokeWidth = 5.0
    }
    
    private func showMarker() {
        if !isMarkerAdded {
            self.mapView.bringSubview(toFront: self.markerView)
            self.markerView.isHidden = false
            self.isMarkerAdded = true
        }
    }
    
    private func removeMarker() {
        self.markerView.isHidden = true
        self.isMarkerAdded = false
    }
    
    // MARK: - IBActions
    @IBAction func moveToCurrentLocation() {
        self.getUserCurrentLocation()
    }
    
    @IBAction func saveClicked() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.delegate?.didLocationSave(lat: self.lat, lng: self.lng, address: self.userAddress)
        self.didTapLeftButton()
    }
}

extension MapVC:LocationManagerDelegate {
    // MARK: - Location
    @objc private func getUserCurrentLocation() {
        self.view.showLoader()
        self.removeMarker()
        LogManager.logMessage(mesage:"Map VC location manager delegate ))")

        locationManager.delegate = self
        if locationManager.locationServicesEnabled() {
            if locationManager.locationHasBeenAsked() {
                locationManager.startLocationUpdating()
            } else {
                //locationManager.askPermissionAndStartLocationUpdate()
                let vc = UIStoryboard.navigateToLocationPermissionVC()
                vc.completion = {  (isAllow) in
                    if isAllow {
                        self.locationManager.askPermissionAndStartLocationUpdate()
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = UIStoryboard.navigateToLocationPermissionVC()
            vc.completion = {  (isAllow) in
                if isAllow {
                    self.locationManager.askPermissionAndStartLocationUpdate()
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Location Delegate
    func locationManagerUserCurrentLocationAndAddress(location: CLLocation, address: String) {
        self.view.hideLoader()
        self.lat = location.coordinate.latitude
        self.lng = location.coordinate.longitude
        self.userAddress = address
        self.locationManager.delegate = nil
        self.addMapView()
    }
    
    func locationManagerFailedToGetLocation(error: Error) {
        self.view.hideLoader()
        var locationError = "Failed to fetch Location."
        if !Utilities.isNetworkReachable() {
            locationError = "Please check your internet connection."
        }
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: locationError, completion: nil)
    }
    
    func locationServiceDisabled() {
        self.view.hideLoader()
        // User Denied Location go to Disabled Location Screen
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
    }
    
    func deviceLocationDisabled() {
        self.view.hideLoader()
        self.locationManager.delegate = nil
        TopMessage.shared.showMessageWithText(text: AppText.LocationDisbaled, completion: nil)
    }
}

extension MapVC: GMSMapViewDelegate {
    // MARK: - MapView Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.lat = position.target.latitude
        self.lng = position.target.longitude
        let location = CLLocation(latitude: self.lat, longitude: self.lng)
        
        locationManager.getAddressFromLocation(location) { strAddress, strFullAddress, _ in
            if (strFullAddress != nil){
                self.userAddress = strFullAddress!
            } else {
                self.userAddress = ""
                TopMessage.shared.showMessageWithText(text: ValidationMessages.addressNotFound, completion: nil)
            }
            self.addressTextField.text = self.userAddress
        }
    }
    
    // MARK: - Places API
    @objc func callPlacesAPI(_ textField:UITextField) {
        self.placesAutoCompleteWithKey(key: textField.text ?? "")
    }
    
    func placesAutoCompleteWithKey(key: String) {
        let filter: GMSAutocompleteFilter = GMSAutocompleteFilter()

        placeClient.autocompleteQuery(key, bounds: nil, filter: filter) { (results, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if error != nil {
                    return
                }
                let arrSugg = NSMutableArray()
                
                self.arrSuggestedSource.removeAllObjects()
                for result in results! {
                    arrSugg.add(result)
                }
                self.arrSuggestedSource = arrSugg
                if self.arrSuggestedSource.count == 0 {
                    self.removePlaceView()
                } else {
                    if self.placeView != nil {
                        self.placeView?.loadTableData(datasource: self.arrSuggestedSource)
                    } else {
                        self.addPlaceView(data: self.arrSuggestedSource)
                    }
                }
            })
        }
    }
}

extension MapVC {
    // MARK: - MAP Overlay
    func appendOverlayCircle() {
        let overlayPath = UIBezierPath(rect:CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - 120))
        let transparentPath = UIBezierPath(arcCenter: CGPoint(x: ScreenSize.SCREEN_WIDTH/2, y: (ScreenSize.SCREEN_HEIGHT - 150)/2), radius: (ScreenSize.SCREEN_WIDTH - 100)/2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        overlayPath.append(transparentPath)
        overlayPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = CustomColor.overlayColor.cgColor
        self.overlayView.layer.addSublayer(fillLayer)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = transparentPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = CustomColor.preferenceSelectionColor.cgColor
        circleLayer.lineWidth = 5
        self.overlayView.layer.addSublayer(circleLayer)
    }
    
    private func showOverlayView() {
        UIView.animate(withDuration: 1.0) {
            self.overlayView.alpha = 1.0
        }
    }
    
    private func hideOverlayView() {
        UIView.animate(withDuration: 1.0) {
            self.overlayView.alpha = 0.0
        }
    }

}

extension MapVC {
    // MARK: - Search Place fun
    func addPlaceView(data:NSMutableArray) {
        self.placeView = PlaceView.placeTable()
        self.placeView?.completion = { (result) in
            self.addressTextField.text = result.attributedFullText.string
            self.placeClient.lookUpPlaceID(result.placeID!) { (place, _) -> Void in
                if place != nil {
                    self.lat = place!.coordinate.latitude
                    self.lng = place!.coordinate.longitude
                }
                self.addMapView()
            }
            self.addressTextField.resignFirstResponder()
            self.removePlaceView()
        }
        self.placeView?.loadTableData(datasource: data)
        
        var newFrame = self.placeView!.frame
        newFrame.origin.x = 20
        newFrame.origin.y = self.addressView.frame.origin.y + self.addressView.frame.size.height + 17
        newFrame.size.width = self.addressView.frame.size.width
        self.placeView!.frame = newFrame
        self.view.addSubview(self.placeView!)
    }
    
    func removePlaceView() {
        self.placeView?.removeFromSuperview()
        if self.placeView != nil {
            self.placeView = nil
        }
    }
}

extension MapVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if (textField.text?.count ?? 0) > 2 {
            self.perform(#selector(callPlacesAPI(_:)), with: textField, afterDelay: 2.0)
        }
        return true
    }
}

extension MapVC:TopBarViewDelegate {
    // MARK: - TopView Delegate
    func didTapLeftButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
