//
//  Location.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Equatable {
    let id = UUID()
    var latitude: Double
    var longitude: Double
    var angle: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
