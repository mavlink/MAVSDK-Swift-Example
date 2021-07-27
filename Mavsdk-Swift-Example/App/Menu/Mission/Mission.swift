//
//  Mission.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/21/21.
//

import Foundation
import Mavsdk
import MapKit


enum Mission: CaseIterable {
    case survey
    case perimeter
    case downloaded
    
    var title: String {
        switch self {
        case .survey:
            return "Survey Mission"
        case .perimeter:
            return "Perimeter Mission"
        case .downloaded:
            return "Downloaded Mission"
        }
    }
    
    func missionPlan(center: CLLocationCoordinate2D) -> Mavsdk.Mission.MissionPlan? {
        switch self {
        case .survey:
            return surveyMissionPlan(center: center)
        case .perimeter:
            return perimeterMissionPlan(center: center)
        case .downloaded:
            return MissionOperator.shared.downloadedMissionPlan
        }
    }
}
