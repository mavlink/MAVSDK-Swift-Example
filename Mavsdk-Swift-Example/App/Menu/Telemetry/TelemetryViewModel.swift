//
//  TelemetryViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 14/05/21.
//

import Foundation
import RxSwift
import Mavsdk
import Combine

final class TelemetryViewModel: ObservableObject {
    @Published private(set) var flightMode = "N/A"
    @Published private(set) var armed = "N/A"
    @Published private(set) var droneCoordinate = "N/A"
    @Published private(set) var droneAltitude = "N/A"
    @Published private(set) var attitudeEuler = "N/A"
    @Published private(set) var cameraAttitudeEuler = "N/A"
    @Published private(set) var battery = "N/A"
    @Published private(set) var gpsInfo = "N/A"
    @Published private(set) var healthAllOk = "N/A"
    @Published private(set) var landedState = "N/A"
    @Published private(set) var health = "N/A"
    
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{ $0 }
            .sink{ [weak self] (drone) in
                self?.observeDroneTelemetry(drone: drone)
            }
    }
    
    func observeDroneTelemetry(drone: Drone) {
        drone.telemetry.flightMode
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (mode) in
                self?.flightMode = String(describing: mode)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.armed
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (armed) in
                self?.armed = armed ? "Armed" : "Disarmed"
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.position
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (position) in
                self?.droneCoordinate = String(format: "lat:%.8f\nlong:%.8f", position.latitudeDeg, position.longitudeDeg)
                self?.droneAltitude = String(format: "absolute:%.2f\nrelative:%.2f", position.absoluteAltitudeM, position.relativeAltitudeM)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.attitudeEuler
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (attitudeEuler) in
                self?.attitudeEuler = String(format: "pitchDeg:%.2f\nyawDeg:%.2f", attitudeEuler.pitchDeg, attitudeEuler.yawDeg)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.cameraAttitudeEuler
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (cameraAttitudeEuler) in
                self?.cameraAttitudeEuler = String(format: "pitchDeg:%.2f\nyawDeg:%.2f", cameraAttitudeEuler.pitchDeg, cameraAttitudeEuler.yawDeg)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.battery
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (battery) in
                self?.battery = String(format: "remainingPercent:%.2f", battery.remainingPercent)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.gpsInfo
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (gpsInfo) in
                self?.gpsInfo = String(format: "fixType:%@\nnumSatellites:%d", String(describing: gpsInfo.fixType), gpsInfo.numSatellites)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.healthAllOk
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (healthAllOk) in
                self?.healthAllOk = healthAllOk ? "OK" : "Not OK"
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.health
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (health) in
                self?.health = """
                                        isAccelerometerCalibrationOk: \(health.isAccelerometerCalibrationOk)
                                        isArmable: \(health.isArmable)
                                        isGlobalPositionOk: \(health.isGlobalPositionOk)
                                        isGyrometerCalibrationOk: \(health.isGyrometerCalibrationOk)
                                        isHomePositionOk: \(health.isHomePositionOk)
                                        isLocalPositionOk: \(health.isLocalPositionOk)
                                        isMagnetometerCalibrationOk: \(health.isMagnetometerCalibrationOk)
                                """
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.landedState
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (landedState) in
                self?.landedState = String(describing: landedState)
            })
            .disposed(by: disposeBag)
    }
}
