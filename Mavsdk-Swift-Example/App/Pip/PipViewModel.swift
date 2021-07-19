//
//  PipViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 14/05/21.
//

import Foundation
import RxSwift
import Mavsdk
import Combine

final class PipViewModel: ObservableObject {
    @Published private(set) var isConnected = false
    
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{$0}
            .sink{ self.observeDroneConnectionState(drone: $0) }
    }
    
    func observeDroneConnectionState(drone: Drone) {
        drone.core.connectionState
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (state) in
                self.isConnected = state.isConnected
            })
            .disposed(by: disposeBag)
    }
}
