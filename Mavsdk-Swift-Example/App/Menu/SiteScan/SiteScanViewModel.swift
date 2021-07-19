//
//  SiteScanViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 20/05/21.
//

import RxSwift
import Mavsdk

final class SiteScanViewModel: ObservableObject {
    lazy var drone = mavsdkDrone.drone
    
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
    
    func preflightCheckListQueue() {
        let routine = Completable.concat([
            cameraCheck().do(onSubscribe: { print("PreFli: -- Camera Check -- ") }),
            missionCheck(SurveyMission.mission).do(onSubscribe: { print("PreFli: -- Mission Check -- ") }),
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
        let stopPhotoInterval = drone!.camera.stopPhotoInterval().do(onSubscribed: { print("PreFli: stopPhotoInterval") })
        let setPhotoMode = drone!.camera.setMode(mode: .photo).do(onSubscribed: { print("PreFli: setPhotoMode") })
        let takePhoto = drone!.camera.takePhoto().do(onSubscribed: { print("PreFli: takePhoto") })
        let listPhotos = drone!.camera.listPhotos(photosRange: .sinceConnection).asCompletable().do(onSubscribed: { print("PreFli: listPhotos") })
        
        return Completable.concat([
            stopPhotoInterval,
            setPhotoMode,
            takePhoto,
            listPhotos
        ])
    }
    
    func batteryCheck() {
        // TODO
    }
    
    func missionCheck(_ missionPlan: Mission.MissionPlan) -> Completable {
        return Completable.concat([
            continueWithoutLinkCheck(),
            setRTLAfterMissionCheck(),
            uploadMissionCheck(missionPlan),
            setRTLAltitudeCheck()
        ])
    }
    
    func swipeToTakeOff() -> Completable {
        let setCurrentMissionItem = drone!.mission.setCurrentMissionItem(index: Int32(0)).do(onSubscribed: { print("PreFli: setCurrentMissionItem") })
        let arm = drone!.action.arm().do(onSubscribed: { print("PreFli: arm") })
        let startMission = drone!.mission.startMission()
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
            drone!.param.setParamInt(name: "NAV_DLL_ACT", value: 0).do(onSubscribed: { print("PreFli: NAV_DLL_ACT") }),
            drone!.param.setParamInt(name: "NAV_RCL_ACT", value: 0).do(onSubscribed: { print("PreFli: NAV_RCL_ACT") })
        ])
    }
    
    func setRTLAfterMissionCheck() -> Completable {
        return drone!.mission.setReturnToLaunchAfterMission(enable: true).do(onSubscribed: { print("PreFli: setReturnToLaunchAfterMission") })
    }
    
    func uploadMissionCheck(_ missionPlan: Mission.MissionPlan) -> Completable {
        let cancelMissionDownload = drone!.mission.cancelMissionDownload().do(onSubscribed: { print("PreFli: cancelMissionDownload") })
        let cancelMissionUpload = drone!.mission.cancelMissionUpload().do(onSubscribed: { print("PreFli: cancelMissionUpload") })
        let uploadMission = drone!.mission.uploadMission(missionPlan: missionPlan)
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
        return drone!.action.setReturnToLaunchAltitude(relativeAltitudeM: 60.0).do(onSubscribed: { print("PreFli: setReturnToLaunchAltitude") })
    }
}
