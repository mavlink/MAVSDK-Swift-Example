//
//  MavsdkExtensions.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas Silva on 17/06/21.
//

import Mavsdk
import MavsdkServer

extension Mission.MissionItem {
    init(latitudeDeg: Double, longitudeDeg: Double, relativeAltitudeM: Float, speedMS: Float, isFlyThrough: Bool, gimbalPitchDeg: Float, gimbalYawDeg: Float, cameraAction: Mission.MissionItem.CameraAction, loiterTimeS: Float, cameraPhotoIntervalS: Double) {
        
        self.init(latitudeDeg: latitudeDeg, longitudeDeg: longitudeDeg, relativeAltitudeM: relativeAltitudeM, speedMS: speedMS, isFlyThrough: isFlyThrough, gimbalPitchDeg: gimbalPitchDeg, gimbalYawDeg: gimbalYawDeg, cameraAction: cameraAction, loiterTimeS: loiterTimeS, cameraPhotoIntervalS: cameraPhotoIntervalS, acceptanceRadiusM: .nan)
    }
}
