//
//  ConnectionViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/12/21.
//

import Foundation
import Mavsdk
import MavsdkServer
import RxSwift
import Combine

final class ConnectionViewModel: ObservableObject {
    @Published var isConnected = false
    
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{$0}
            .sink{ [weak self] in
                self?.observeDroneConnectionState(drone: $0)
            }
    }
    
    func observeDroneConnectionState(drone: Drone) {
        drone
            .core.connectionState
            .subscribe(on: MavScheduler)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (state) in
                self?.isConnected = state.isConnected
            })
            .disposed(by: disposeBag)
    }
}
