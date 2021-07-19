//
//  SurveyMission.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 20/05/21.
//

import Mavsdk

struct SurveyMission {
    static var mission: Mission.MissionPlan {
        Mission.MissionPlan(missionItems: missionItems())
    }

    static func missionItems() -> [Mission.MissionItem] {
        return [
            Mission.MissionItem(
            latitudeDeg : 37.4135427,
            longitudeDeg : -121.9965498,
            relativeAltitudeM : 91.44,
            speedMS : 8.0,
            isFlyThrough : false,
            gimbalPitchDeg : 0.0,
            gimbalYawDeg : 50.98875,
            cameraAction : .stopPhotoInterval,
            loiterTimeS : .nan,
            cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.413907926402395,
                longitudeDeg : -121.9959821853315,
                relativeAltitudeM : 91.44,
                speedMS : 8.0,
                isFlyThrough : false,
                gimbalPitchDeg : 0.0,
                gimbalYawDeg : 50.98875,
                cameraAction : .stopPhotoInterval,
                loiterTimeS : .nan,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.413907926402395,
                longitudeDeg : -121.9959821853315,
                relativeAltitudeM : 60.96,
                speedMS : 8.0,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : -90.0,
                cameraAction : .stopPhotoInterval,
                loiterTimeS : .nan,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.413907926402395,
                longitudeDeg : -121.9959821853315,
                relativeAltitudeM : 60.36,
                speedMS : 4.69392,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : -90.0,
                cameraAction : .startPhotoInterval,
                loiterTimeS : 4.0,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.413907926402395,
                longitudeDeg : -121.99711661466849,
                relativeAltitudeM : 60.96,
                speedMS : 8.0,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : -90.0,
                cameraAction : .stopPhotoInterval,
                loiterTimeS : .nan,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.413684920839984,
                longitudeDeg : -121.99711661466849,
                relativeAltitudeM : 60.96,
                speedMS : 4.69392,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : 90.0,
                cameraAction : .startPhotoInterval,
                loiterTimeS : 4.0,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.413684920839984,
                longitudeDeg : -121.9959821853315,
                relativeAltitudeM : 60.96,
                speedMS : 8.0,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : 90.0,
                cameraAction : .stopPhotoInterval,
                loiterTimeS : .nan,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.41346191461363,
                longitudeDeg : -121.9959821853315,
                relativeAltitudeM : 60.96,
                speedMS : 4.69392,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : -90.0,
                cameraAction : .startPhotoInterval,
                loiterTimeS : 4.0,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.41346191461363,
                longitudeDeg : -121.99711661466849,
                relativeAltitudeM : 60.96,
                speedMS : 8.0,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : -90.0,
                cameraAction : .stopPhotoInterval,
                loiterTimeS : .nan,
                cameraPhotoIntervalS : 3.0),

            Mission.MissionItem(
                latitudeDeg : 37.41323890772332,
                longitudeDeg : -121.99711661466849,
                relativeAltitudeM : 60.96,
                speedMS : 4.69392,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : 90.0,
                cameraAction : .startPhotoInterval,
                loiterTimeS : 4.0,
                cameraPhotoIntervalS : 3.0),



            Mission.MissionItem(
                latitudeDeg : 37.41323890772332,
                longitudeDeg : -121.9959821853315,
                relativeAltitudeM : 60.96,
                speedMS : 8.0,
                isFlyThrough : false,
                gimbalPitchDeg : -90.0,
                gimbalYawDeg : 90.0,
                cameraAction : .stopPhotoInterval,
                loiterTimeS : 2.0,
                cameraPhotoIntervalS : 3.0)

        ]
    }
}
