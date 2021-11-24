//
//  MissionOperator.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/19/21.
//

import Foundation
import Mavsdk
import MapKit

final class MissionOperator: ObservableObject {
    static let shared = MissionOperator()
    
    var missions: [Mission] = Mission.allCases
    var currentMissionPlan: Mavsdk.Mission.MissionPlan? {
        didSet {
            missionPlanCoordinates = currentMissionPlan?.missionItems
                .map{ CLLocationCoordinate2D(latitude: $0.latitudeDeg, longitude: $0.longitudeDeg) } ?? []
        }
    }
    private(set) var downloadedMissionPlan: Mavsdk.Mission.MissionPlan? {
        didSet {
            updateMissionPlan()
        }
    }

    var mapCenterCoordinate = CLLocationCoordinate2D(latitude: 37.4135427, longitude: -121.99655)
    @Published var missionPlanCoordinates = [CLLocationCoordinate2D]()
    var startCoordinate = CLLocationCoordinate2D(latitude: 37.4135427, longitude: -121.99655) {
        didSet {
            updateMissionPlan()
        }
    }
    
    @Published var currentMission: Mission? {
        didSet {
            updateMissionPlan()
        }
    }
    
    func selectMission(_ mission: Mission?) {
        if currentMission == mission || mission == nil {
            currentMission = nil
            return
        }
        
        startCoordinate = mapCenterCoordinate
        currentMission = mission
    }
    
    func updateMissionPlan() {
        currentMissionPlan = currentMission?.missionPlan(center: startCoordinate)
    }
    
    func moveMissionPlan(to coord: CLLocationCoordinate2D) {
        startCoordinate = coord
    }
    
    func centerToMap() {
        moveMissionPlan(to: mapCenterCoordinate)
    }
    
    func addDownloadedMission(plan: Mavsdk.Mission.MissionPlan) {
        downloadedMissionPlan = plan
    }
    
    func removeDownloaededMissionPlan() {
        downloadedMissionPlan = nil
    }
}
