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
    case surveyNadir
    case survey75
    case perimeter
    case downloaded
    
    var title: String {
        switch self {
        case .surveyNadir:
            return "Survey Nadir Mission"
        case .survey75:
            return "Survey 75° Gimbal Mission"
        case .perimeter:
            return "Perimeter Mission"
        case .downloaded:
            return "Downloaded Mission"
        }
    }
    
    func missionPlan(center: CLLocationCoordinate2D) -> Mavsdk.Mission.MissionPlan? {
        switch self {
        case .surveyNadir:
            return surveyMissionPlan(center: center, gimbalPitchDeg: -90)
        case .survey75:
            return surveyMissionPlan(center: center, gimbalPitchDeg: -75)
        case .perimeter:
            return perimeterMissionPlan(center: center)
        case .downloaded:
            return MissionOperator.shared.downloadedMissionPlan
        }
    }
}
