//
//  SiteScanMavsdk.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas on 20/05/21.
//

import RxSwift
import Mavsdk

class SiteScanMavsdk: ObservableObject {
    
    var drone: Drone = mavsdkDrone.drone!
    var disposeBag = DisposeBag()
    
    // Vars for preflight check
    var aircraftHealth: Telemetry.Health?
    
    init() {
        addObservers()
    }
    
// MARK: - Add Observers
    func addObservers() {
        coreObservers()
        telemetryObservers()
        infoObservers()
        cameraObservers()
    }
    
    // Core
    func coreObservers() {
        connectionState()
    }
    
    // Telemetry
    func telemetryObservers() {
        health()
        position()
        attitudeEuler()
        home()
        cameraAttitudeEuler()
        gpsInfo()
        rcStatus()
        armed()
        statusText()
        positionVelocityNed()
        flightMode()
        battery()
    }
    
    // Info
    func infoObservers() {
        getIdentification()
        getProduct()
        getFlightInformation()
        getVersion()
    }
    
    // Camera
    func cameraObservers() {
        information()
        videoStreamInfo()
        mode()
        captureInfo()
        currentSettings()
        possibleSettingOptions()
        status()
    }
}

// MARK: - Core Observers
extension SiteScanMavsdk {
    func connectionState() {
        drone.core.connectionState
            .distinctUntilChanged()
            .subscribe(onNext: { (connectionState) in
                print("+DC+ core connectionState: \(connectionState.isConnected)")
            }, onError: { error in
                print("+DC+ core connectionState error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Telemetry Observers
extension SiteScanMavsdk {
    func health() {
        drone.telemetry.health
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { health in
                self.aircraftHealth = health
                print("+DC+ telemetry health: \(health)")
            }, onError: { error in
                print("+DC+ telemetry health error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func position() {
        drone.telemetry.position
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { position in
                print("+DC+ telemetry position: \(position)")
            }, onError: { error in
                print("+DC+ telemetry position error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func attitudeEuler() {
        drone.telemetry.attitudeEuler
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { attitudeEuler in
                print("+DC+ telemetry attitudeEuler: \(attitudeEuler)")
            }, onError: { error in
                print("+DC+ telemetry attitudeEuler error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func home() {
        drone.telemetry.home
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { home in
                print("+DC+ telemetry home: \(home)")
            }, onError: { error in
                print("+DC+ telemetry home error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func cameraAttitudeEuler() {
        drone.telemetry.cameraAttitudeEuler
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { cameraAttitudeEuler in
                print("+DC+ telemetry cameraAttitudeEuler: \(cameraAttitudeEuler)")
            }, onError: { error in
                print("+DC+ telemetry cameraAttitudeEuler error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func gpsInfo() {
        drone.telemetry.gpsInfo
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { gpsInfo in
                print("+DC+ telemetry gpsInfo: \(gpsInfo)")
            }, onError: { error in
                print("+DC+ telemetry gpsInfo error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func rcStatus() {
        drone.telemetry.rcStatus
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { rcStatus in
                print("+DC+ telemetry rcStatus: \(rcStatus)")
            }, onError: { error in
                print("+DC+ telemetry rcStatus error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func armed() {
        drone.telemetry.armed
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { armed in
                print("+DC+ telemetry armed: \(armed)")
            }, onError: { error in
                print("+DC+ telemetry armed error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func statusText() {
        drone.telemetry.statusText
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { statusText in
                print("+DC+ telemetry statusText: \(statusText)")
            }, onError: { error in
                print("+DC+ telemetry statusText error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func positionVelocityNed() {
        drone.telemetry.positionVelocityNed
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { positionVelocityNed in
                print("+DC+ telemetry positionVelocityNed: \(positionVelocityNed)")
            }, onError: { error in
                print("+DC+ telemetry positionVelocityNed error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func flightMode() {
        drone.telemetry.flightMode
            .subscribe(onNext: { value in
                print("+DC+ telemetry flightMode: \(value)")
            }, onError: { error in
                print("+DC+ telemetry flightMode error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func battery() {
        drone.telemetry.battery
            .subscribe(onNext: { value in
                print("+DC+ telemetry battery: \(value)")
            }, onError: { error in
                print("+DC+ telemetry battery error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Info Observers
extension SiteScanMavsdk {
    func getIdentification() {
        drone.info.getIdentification()
            .subscribe(onSuccess: { value in
                print("+DC+ info getIdentification: \(value)")
            }, onError: { (error) in
                print("+DC+ info getIdentification error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func getProduct() {
        drone.info.getProduct()
            .subscribe(onSuccess: { value in
                print("+DC+ info getProduct: \(value)")
            }, onError: { (error) in
                print("+DC+ info getProduct error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func getFlightInformation() {
        drone.info.getFlightInformation()
            .subscribe(onSuccess: { value in
                print("+DC+ info getFlightInformation: \(value)")
            }, onError: { (error) in
                print("+DC+ info getFlightInformation error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func getVersion() {
        drone.info.getVersion()
            .subscribe(onSuccess: { value in
                print("+DC+ info getVersion: \(value)")
            }, onError: { (error) in
                print("+DC+ info getVersion error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Camera
extension SiteScanMavsdk {
    // Observers
    func information() {
        drone.camera.information
            .subscribe(onNext: { value in
                print("+DC+ camera information: \(value)")
            }, onError: { error in
                print("+DC+ camera information error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func videoStreamInfo() {
        drone.camera.videoStreamInfo
            .subscribe(onNext: { value in
                print("+DC+ camera videoStreamInfo: \(value)")
            }, onError: { error in
                print("+DC+ camera videoStreamInfo error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func mode() {
        drone.camera.mode
            .subscribe(onNext: { value in
                print("+DC+ camera mode: \(value)")
            }, onError: { error in
                print("+DC+ camera mode error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func captureInfo() {
        drone.camera.captureInfo
            .subscribe(onNext: { value in
                print("+DC+ camera captureInfo: \(value)")
            }, onError: { error in
                print("+DC+ camera captureInfo error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func currentSettings() {
        drone.camera.currentSettings
            .subscribe(onNext: { value in
                print("+DC+ camera currentSettings: \(value)")
            }, onError: { error in
                print("+DC+ camera currentSettings error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func possibleSettingOptions() {
        drone.camera.possibleSettingOptions
            .subscribe(onNext: { value in
                print("+DC+ camera possibleSettingOptions: \(value)")
            }, onError: { error in
                print("+DC+ camera possibleSettingOptions error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func status() {
        drone.camera.status
            .subscribe(onNext: { value in
                print("+DC+ camera status: \(value)")
            }, onError: { error in
                print("+DC+ camera status error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    // Actions
    func formatStorage() {
        drone.camera.formatStorage()
            .subscribe(onCompleted: {
                print("+DC+ camera formatStorage completed.")
            }, onError: { (error) in
                print("+DC+ camera formatStorage error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func takePhoto() {
        drone.camera.takePhoto()
            .subscribe(onCompleted: {
                print("+DC+ camera takePhoto completed.")
            }, onError: { (error) in
                print("+DC+ camera takePhoto error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func listPhotos() {
        drone.camera.listPhotos(photosRange: .sinceConnection)
            .subscribe(onSuccess: { (value) in
                print("+DC+ camera listPhotos \(value).")
            }, onError: { (error) in
                print("+DC+ camera listPhotos error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func startPhotoInterval() {
        drone.camera.startPhotoInterval(intervalS: 3)
            .subscribe(onCompleted: {
                print("+DC+ camera startPhotoInterval completed.")
            }, onError: { (error) in
                print("+DC+ camera startPhotoInterval error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func stopPhotoInterval() {
        drone.camera.stopPhotoInterval()
            .subscribe(onCompleted: {
                print("+DC+ camera stopPhotoInterval completed.")
            }, onError: { (error) in
                print("+DC+ camera stopPhotoInterval error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func startVideo() {
        drone.camera.startVideo()
            .subscribe(onCompleted: {
                print("+DC+ camera startVideo completed.")
            }, onError: { (error) in
                print("+DC+ camera startVideo error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func stopVideo() {
        drone.camera.stopVideo()
            .subscribe(onCompleted: {
                print("+DC+ camera stopVideo completed.")
            }, onError: { (error) in
                print("+DC+ camera stopVideo error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func setModeCamera() {
        drone.camera.setMode(mode: .photo)
            .subscribe(onCompleted: {
                print("+DC+ camera setMode completed.")
            }, onError: { (error) in
                print("+DC+ camera setMode error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func setSettings(_ settings: Camera.Setting) {
        drone.camera.setSetting(setting: settings)
            .subscribe(onCompleted: {
                print("+DC+ camera setSetting completed.")
            }, onError: { (error) in
                print("+DC+ camera setSetting error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Action
extension SiteScanMavsdk {
    func arm() {
        drone.action.arm()
            .subscribe(onCompleted: {
                print("+DC+ acion arm completed.")
            }, onError: { (error) in
                print("+DC+ action arm error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func returnToLaunch() {
        drone.action.returnToLaunch()
            .subscribe(onCompleted: {
                print("+DC+ acion returnToLaunch completed.")
            }, onError: { (error) in
                print("+DC+ action returnToLaunch error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func setReturnToLaunchAltitude() {
        drone.action.setReturnToLaunchAltitude(relativeAltitudeM: 60.0)
            .subscribe(onCompleted: {
                print("+DC+ action setReturnToLaunchAltitude completed.")
            }, onError: { (error) in
                print("+DC+ action setReturnToLaunchAltitude error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Mission
extension SiteScanMavsdk {
    // Observers
    func missionProgress() {
        drone.mission.missionProgress
            .subscribe(onNext: { value in
                print("+DC+ mission missionProgress: \(value)")
            }, onError: { error in
                print("+DC+ mission missionProgress error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    
    // Actions
    func setCurrentMissionItem(_ index: Int) {
        drone.mission.setCurrentMissionItem(index: Int32(index))
            .subscribe(onCompleted: {
                print("+DC+ mission setCurrentMissionItem completed.")
            }, onError: { (error) in
                print("+DC+ mission setCurrentMissionItem error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func startMission() {
        drone.mission.startMission()
            .subscribe(onCompleted: {
                print("+DC+ mission startMission completed.")
            }, onError: { (error) in
                print("+DC+ mission startMission error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func pauseMission() {
        drone.mission.pauseMission()
            .subscribe(onCompleted: {
                print("+DC+ mission pauseMission completed.")
            }, onError: { (error) in
                print("+DC+ mission pauseMission error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func clearMission() {
        drone.mission.clearMission()
            .subscribe(onCompleted: {
                print("+DC+ mission clearMission completed.")
            }, onError: { (error) in
                print("+DC+ mission clearMission error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func uploadMission(_ missionPlan: Mission.MissionPlan) {
        drone.mission.uploadMission(missionPlan: missionPlan)
            .subscribe(onCompleted: {
                print("+DC+ mission uploadMission completed.")
            }, onError: { (error) in
                print("+DC+ mission uploadMission error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func cancelMissionUpload() {
        drone.mission.cancelMissionUpload()
            .subscribe(onCompleted: {
                print("+DC+ mission cancelMissionUpload completed.")
            }, onError: { (error) in
                print("+DC+ mission cancelMissionUpload error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func cancelMissionDownload() {
        drone.mission.cancelMissionDownload()
            .subscribe(onCompleted: {
                print("+DC+ mission cancelMissionDownload completed.")
            }, onError: { (error) in
                print("+DC+ mission cancelMissionDownload error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func downloadMission() {
        drone.mission.downloadMission()
            .subscribe(onSuccess: { (value) in
                print("+DC+ mission downloadMission \(value).")
            }, onError: { (error) in
                print("+DC+ mission downloadMission error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func setReturnToLaunchAfterMission() {
        drone.mission.setReturnToLaunchAfterMission(enable: true)
            .subscribe(onCompleted: {
                print("+DC+ mission setReturnToLaunchAfterMission completed.")
            }, onError: { (error) in
                print("+DC+ mission setReturnToLaunchAfterMission error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Gimbal
extension SiteScanMavsdk {
    // Actions
    func setModeGimbal() {
        drone.gimbal.setMode(gimbalMode: .yawFollow)
            .subscribe(onCompleted: {
                print("+DC+ gimbal setMode completed.")
            }, onError: { (error) in
                print("+DC+ gimbal setMode error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func setPitchAndYaw() {
        drone.gimbal.setPitchAndYaw(pitchDeg: -30.0, yawDeg: 0.0)
            .subscribe(onCompleted: {
                print("+DC+ gimbal setPitchAndYaw completed.")
            }, onError: { (error) in
                print("+DC+ gimbal setPitchAndYaw error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Param
extension SiteScanMavsdk {
    // Actions
    func setParamFloat() {
        drone.param.setParamFloat(name: "COM_RC_LOSS_MAN", value: 0.0)
            .subscribe(onCompleted: {
                print("+DC+ param setParamFloat completed.")
            }, onError: { (error) in
                print("+DC+ param setParamFloat error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func setParamInt() {
        drone.param.setParamInt(name: "NAV_DLL_ACT", value: 2)
            .subscribe(onCompleted: {
                print("+DC+ param setParamInt completed.")
            }, onError: { (error) in
                print("+DC+ param setParamInt error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
}
