//
//  GMSMapView + Extension.swift
//  Steve
//
//  Created by Parth Grover on 3/14/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

extension GMSMapView {
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.center
        let centerCoordinate = self.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = self.convert(CGPoint(x: self.frame.size.width, y: 0), from: self)
        let point = self.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
    
    func animateToFitCircleOn(center: CLLocationCoordinate2D, radius: CLLocationDistance, circleRatio: Double) {
        let centerPoint = projection.point(for: center)
        // Tính w
        let halfWidth = radius / circleRatio
        // Tính h
        let halfHeight = halfWidth / Double(self.bounds.width / self.bounds.height)
        // Tính c
        let halfCross = sqrt(halfWidth * halfWidth + halfHeight * halfHeight)
        let radiusInView = projection.points(forMeters: halfCross, at: center)
        // Tính góc alpha, beta
        let beta = atan(halfHeight / halfWidth)
        let alpha = beta - .pi
        var topLeftPoint = CGPoint()
        var bottomRightPoint = CGPoint()
        // Tính toạ độ top left, bottom right: CGPoint
        topLeftPoint.x = centerPoint.x + radiusInView * CGFloat(cos(alpha))
        topLeftPoint.y = centerPoint.y + radiusInView * CGFloat(sin(alpha))
        bottomRightPoint.x = centerPoint.x + radiusInView * CGFloat(cos(beta))
        bottomRightPoint.y = centerPoint.y + radiusInView * CGFloat(sin(beta))
        // Convert sang toạ độ latitude, longitude
        let topLeft = projection.coordinate(for: topLeftPoint)
        let bottomRight = projection.coordinate(for: bottomRightPoint)
        let bounds = GMSCoordinateBounds(coordinate: topLeft, coordinate: bottomRight)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 0.0)
        animate(with: cameraUpdate)
    }
}

extension GMSMapView {
    func setMapStyle() {
        do {
            if let styleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}
