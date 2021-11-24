//
//  DroneAnnotation.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/26/21.
//

import Foundation
import MapKit


class DroneAnnotation: NSObject, ObservableObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    @objc dynamic var heading: Double = 0
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
