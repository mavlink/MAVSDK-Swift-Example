//
//  MissionMapTitleAnnotation.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/26/21.
//

import Foundation
import MapKit


class MissionMapTitleAnnotation: NSObject, ObservableObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
   
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
