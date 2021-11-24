//
//  TelemetryDetailViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 21/05/21.
//

import Foundation
import RxSwift
import Mavsdk
import Combine

final class TelemetryDetailViewModel: ObservableObject {
    @Published private(set) var altitude = 0
    @Published private(set) var battery = 0
    @Published private(set) var photosTaken = 0
    @Published private(set) var missionProgressCurrent: Double = 0
    @Published private(set) var missionProgressTotal: Double = 0
    
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{$0}
            .sink{ [weak self] drone in
                self?.observeDroneTelemetry(drone: drone)
                self?.observeMissionProgress(drone: drone)
                self?.observeCameraUpdates(drone: drone)
            }
    }
    
    func observeDroneTelemetry(drone: Drone) {
        drone.telemetry.position
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (position) in
                self?.altitude = Int(position.relativeAltitudeM)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.battery
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (info) in
                self?.battery = Int(info.remainingPercent * 100)
            })
            .disposed(by: disposeBag)
    }
    
    func observeCameraUpdates(drone: Drone) {
        drone.camera.captureInfo
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (info) in
                self?.photosTaken = Int(info.index)
            })
            .disposed(by: disposeBag)

    }
    
    func observeMissionProgress(drone: Drone) {
        drone.mission.missionProgress
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (progress) in
                self?.missionProgressCurrent = Double(progress.current)
                self?.missionProgressTotal = Double(progress.total)
            })
            .disposed(by: disposeBag)
    }
}
