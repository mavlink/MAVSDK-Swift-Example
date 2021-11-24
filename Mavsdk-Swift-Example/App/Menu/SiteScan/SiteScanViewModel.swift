//
//  SiteScanViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 20/05/21.
//

import RxSwift
import Mavsdk
import CoreLocation

final class SiteScanViewModel: ObservableObject {
    let drone = mavsdkDrone.drone!
    
    var siteScan: SiteScanMavsdk?
    let disposeBag = DisposeBag()
    
    init() {}
    
    // -- Order of Checks --
    // stopPhotoInterval
    // takePhoto
    // listPhotos
    // continueWithoutLinkCheck()
    // setReturnToLaunchAfterMission
    // cancelMissionDownload
    // cancelMissionUpload
    // uploadMission
    // setReturnToLaunchAltitude
    // setCurrentMissionItem
    // arm
    // startMission
    
    func subscribeToAllSiteScan() {
        siteScan = SiteScanMavsdk()
    }
    
    func printMessage(_ message: String) -> Completable {
        Completable.create { comlp in
            DispatchQueue.main.async {
                MessageViewModel.shared.message = message
            }
            comlp(.completed)
            return Disposables.create()
        }
    }
    
    func uploadMission() {
        
        guard let position = siteScan?.dronePosition else {
            MessageViewModel.shared.message = "No drone position"
            return
        }
        
        let droneCoord = CLLocationCoordinate2D(latitude: position.latitudeDeg, longitude: position.longitudeDeg)
        MissionOperator.shared.startCoordinate = droneCoord
        MissionOperator.shared.currentMission = Mission.perimeter
        
        guard let missionPlan = MissionOperator.shared.currentMissionPlan else {
            MessageViewModel.shared.message = "No mission selected to upload"
            return
        }
        
        drone.mission.uploadMission(missionPlan: missionPlan)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .do(onError: { (error) in
                MessageViewModel.shared.message = "Error Uploading Mission \(error)"
            }, onCompleted: {
                MessageViewModel.shared.message = "Mission Uploaded"
            }, onSubscribe: {
                MessageViewModel.shared.message = "Uploading Mission"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func preflightCheckListQueue() {
        guard let currentMissionPlan = MissionOperator.shared.currentMissionPlan else {
            print("PreFli: no mission plan selected")
            return
        }
        
        let routine = Completable.concat([
            cameraCheck().do(onSubscribe: { print("PreFli: -- Camera Check -- ") }),
            missionCheck(currentMissionPlan).do(onSubscribe: { print("PreFli: -- Mission Check -- ") }),
            swipeToTakeOff().do(onSubscribe: { print("PreFli: -- Swipe Takeoff -- ") })
        ])
        
        routine
            .subscribeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
            .do(onError: { (error) in
                print("PreFli: Error \(error)")
            }, onCompleted: {
                print("PreFli: Mission Started!")
            }, onSubscribe: {
                print("PreFli: Checking...")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func aircraftCheck() {
        // TODO
    }
    
    func cameraCheck() -> Completable {
        let stopPhotoInterval = drone.camera.stopPhotoInterval().do(onSubscribed: { print("PreFli: stopPhotoInterval") })
        let setPhotoMode = drone.camera.setMode(mode: .photo).do(onSubscribed: { print("PreFli: setPhotoMode") })
        let takePhoto = drone.camera.takePhoto().do(onSubscribed: { print("PreFli: takePhoto") })
        let listPhotos = drone.camera.listPhotos(photosRange: .sinceConnection).asCompletable().do(onSubscribed: { print("PreFli: listPhotos") })
        
        return Completable.concat([
            stopPhotoInterval,
            setPhotoMode,
            takePhoto,
            listPhotos
        ])
    }
    
    /// config == 1 for day light, config == 2 for low light
    func cameraSettingsCheck(_ config: Int) {
        // Exposure mode
        // ISO
        // Shutter Speed
        // Aperture
        // Focus mode
        
        var checks = [Completable]()
        
        do {
            let optionID = config == 1 ? "0" : "13"// "0" Manual/ "13" Shutter priority
            let option = Camera.Option(optionID: optionID, optionDescription: "")
            let setting = Camera.Setting(settingID: "CAM_EXPMODE", settingDescription: "", option: option, isRange: false)
            let check = printMessage("CamSettingCheck: exposure mode")
                .andThen(drone.camera.setSetting(setting: setting))
                
            checks.append(check)
        }
        
        do {
            let optionID = config == 1 ? "0" : "3"// "0" Auto/ "3" ISO 100
            let option = Camera.Option(optionID: optionID, optionDescription: "")
            let setting = Camera.Setting(settingID: "CAM_ISO", settingDescription: "", option: option, isRange: false)
            let check = printMessage("CamSettingCheck: ISO")
                        .andThen(drone.camera.setSetting(setting: setting))
            checks.append(check)
        }
        
        do {
            let optionID = config == 1 ? "49" : "45"// "49" shutter 1/2500/ "45" shutter 1/1000
            let option = Camera.Option(optionID: optionID, optionDescription: "")
            let setting = Camera.Setting(settingID: "CAM_SHUTTER", settingDescription: "", option: option, isRange: false)
            let check = printMessage("CamSettingCheck: Shutter speed")
                .andThen(drone.camera.setSetting(setting: setting))

            checks.append(check)
        }
       
        do {
            if config == 2 {
                let optionID = "9"//
                let option = Camera.Option(optionID: optionID, optionDescription: "")
                let setting = Camera.Setting(settingID: "CAM_APERTURE", settingDescription: "", option: option, isRange: false)
                let check = printMessage("CamSettingCheck: Aperture")
                    .andThen(drone.camera.setSetting(setting: setting))

                checks.append(check)
            }
        }
        
        do {
            let optionID = "0" // "0" infinity
            let option = Camera.Option(optionID: optionID, optionDescription: "")
            let setting = Camera.Setting(settingID: "CAM_FOCUSMODE", settingDescription: "", option: option, isRange: false)
            let check = printMessage("CamSettingCheck: Focus mode")
                .andThen(drone.camera.setSetting(setting: setting))

            checks.append(check)
        }
        
        Completable.concat(checks)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .do(onError: { (error) in
                MessageViewModel.shared.message = "Error CameraSettingsCheck \(error)"
            }, onCompleted: {
                MessageViewModel.shared.message = "CameraSettingsCheck completed. Configuration: \(config)"
            }, onSubscribe: {
                MessageViewModel.shared.message = "CameraSettingsCheck started. Configuration: \(config)"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func batteryCheck() {
        // TODO
    }
    
    func missionCheck(_ missionPlan: Mavsdk.Mission.MissionPlan) -> Completable {
        return Completable.concat([
            continueWithoutLinkCheck(),
            setRTLAfterMissionCheck(),
            uploadMissionCheck(missionPlan),
            setRTLAltitudeCheck()
        ])
    }
    
    func swipeToTakeOff() -> Completable {
        let setCurrentMissionItem = drone.mission.setCurrentMissionItem(index: Int32(0)).do(onSubscribed: { print("PreFli: setCurrentMissionItem") })
        let arm = drone.action.arm().do(onSubscribed: { print("PreFli: arm") })
        let startMission = drone.mission.startMission()
            .do(onError: { (error) in
                print("PreFli: Error \(error)")
            }, onCompleted: {
                print("PreFli: Mission Started!")
            }, onSubscribe: {
                print("PreFli: Checking...")
            })
        
        return Completable.concat([
            setCurrentMissionItem,
            arm,
            startMission
        ])
    }
}

// MARK: - Mission Check
extension SiteScanViewModel {
    func continueWithoutLinkCheck() -> Completable {
        return Completable.concat([
            drone.param.setParamInt(name: "NAV_DLL_ACT", value: 0).do(onSubscribed: { print("PreFli: NAV_DLL_ACT") }),
            drone.param.setParamInt(name: "NAV_RCL_ACT", value: 0).do(onSubscribed: { print("PreFli: NAV_RCL_ACT") })
        ])
    }
    
    func setRTLAfterMissionCheck() -> Completable {
        return drone.mission.setReturnToLaunchAfterMission(enable: true).do(onSubscribed: { print("PreFli: setReturnToLaunchAfterMission") })
    }
    
    func uploadMissionCheck(_ missionPlan: Mavsdk.Mission.MissionPlan) -> Completable {
        let cancelMissionDownload = drone.mission.cancelMissionDownload().do(onSubscribed: { print("PreFli: cancelMissionDownload") })
        let cancelMissionUpload = drone.mission.cancelMissionUpload().do(onSubscribed: { print("PreFli: cancelMissionUpload") })
        let uploadMission = drone.mission.uploadMission(missionPlan: missionPlan)
            .do(onError: { (error) in
                print("PreFli: error uploadMission")
            }, onCompleted: {
                print("PreFli: finished uploadMission")
            }, onSubscribe: {
                print("PreFli: start uploadMission")
            })
        
        return Completable.concat([
            cancelMissionDownload,
            cancelMissionUpload,
            uploadMission
        ])
    }
    
    func setRTLAltitudeCheck() -> Completable {
        return drone.action.setReturnToLaunchAltitude(relativeAltitudeM: 60.0).do(onSubscribed: { print("PreFli: setReturnToLaunchAltitude") })
    }
}
