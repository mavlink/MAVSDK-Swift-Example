import Foundation
import Mavsdk
import MapKit

class ExampleMission {

    var missionItems = [Mission.MissionItem]()

    init() {
        if missionItems.isEmpty {
            missionItems = [Mission.MissionItem]()

            missionItems.append(createWaypoint(47.398039859999997, 8.5455725400000002, .startPhotoInterval))
            missionItems.append(createWaypoint(47.398036222362471, 8.5450146439425509, .stopPhotoInterval))
            missionItems.append(createWaypoint(47.397825620791885, 8.5450092830163271, .none))
            missionItems.append(createWaypoint(47.397832880000003, 8.5455939999999995, .takePhoto))
        }
    }

    private func createWaypoint(_ latitudeDeg: Double, _ longitudeDeg: Double, _ cameraAction: Mission.MissionItem.CameraAction = .none) -> Mission.MissionItem {
        return Mission.MissionItem(latitudeDeg: latitudeDeg, longitudeDeg: longitudeDeg, relativeAltitudeM: 10.0, speedMS: 10.0, isFlyThrough: true, gimbalPitchDeg: Float.nan, gimbalYawDeg: Float.nan, cameraAction: cameraAction, loiterTimeS: Float.nan, cameraPhotoIntervalS: 1)
        
    }

    func generateSampleMissionForLocation(location: CLLocation) {
        missionItems.removeAll()

        missionItems.append(createWaypoint(location.coordinate.latitude, location.coordinate.longitude, .startPhotoInterval))

        let location2 = self.computeLocation(location, 40, 270)
        missionItems.append(createWaypoint(location2.coordinate.latitude, location2.coordinate.longitude, .stopPhotoInterval))

        let location3 = self.computeLocation(location2, 20, 180)
        missionItems.append(createWaypoint(location3.coordinate.latitude, location3.coordinate.longitude, .none))

        let location4 = self.computeLocation(location3, 40, 90)
        missionItems.append(createWaypoint(location4.coordinate.latitude, location4.coordinate.longitude, .takePhoto))
    }

    private func computeLocation(_ locationInit: CLLocation, _ radius: Double, _ bearing: Double) -> CLLocation {
        let earthRadius: Double = 6371000
        let bearingRadius: Double = ((.pi * bearing) / 180)
        let latitudeRadius: Double = ((.pi * (locationInit.coordinate.latitude)) / 180)
        let longitudeRadius: Double = ((.pi * (locationInit.coordinate.longitude)) / 180)

        let computedLatitude: Double = asin(sin(latitudeRadius) * cos(radius / earthRadius) + cos(latitudeRadius) * sin(radius / earthRadius) * cos(bearingRadius))
        let computedLongitude: Double = longitudeRadius + atan2(sin(bearingRadius) * sin(radius / earthRadius) * cos(latitudeRadius), cos(radius / earthRadius) - sin(latitudeRadius) * sin(computedLatitude))

        let computedLoc = CLLocation(latitude: ((computedLatitude) * (180.0 / .pi)), longitude: ((computedLongitude) * (180.0 / .pi)))

        return computedLoc
    }
}
