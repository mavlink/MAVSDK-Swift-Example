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
    
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{$0}
            .sink{ self.observeDroneTelemetry(drone: $0) }
    }
    
    func observeDroneTelemetry(drone: Drone) {
        drone.telemetry.position
            .observeOn(MainScheduler.instance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (position) in
                self.altitude = Int(position.relativeAltitudeM)
            })
            .disposed(by: disposeBag)
        
        drone.telemetry.battery
            .observeOn(MainScheduler.instance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (info) in
                self.battery = Int(info.remainingPercent * 100)
            })
            .disposed(by: disposeBag)
        
        drone.camera.captureInfo
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (info) in
                self.photosTaken = Int(info.index)
            })
            .disposed(by: disposeBag)
    }
}
