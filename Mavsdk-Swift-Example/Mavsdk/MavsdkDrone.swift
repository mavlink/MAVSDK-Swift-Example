//
//  MavsdkDrone.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import Foundation
import Mavsdk
import MavsdkServer
import RxSwift

let MavScheduler = ConcurrentDispatchQueueScheduler(qos: .default)

class MavsdkDrone: ObservableObject {    
    @Published var drone: Drone?
    @Published var systemAddress: String?
    @Published var serverStarted: Bool = false
    @Published var isConnected: Bool = false
    
    private var disposeBag = DisposeBag()
    private var mavsdkServer: MavsdkServer?
    
    func startServer(systemAddress: String) {
        self.systemAddress = systemAddress
        mavsdkServer = MavsdkServer()
        let port = mavsdkServer!.run(systemAddress: systemAddress)
        drone = Drone(port: Int32(port))
        _ = drone!.core.setMavlinkTimeout(timeoutS: 2.0).subscribe()
        serverStarted = true
        subscribeOnConnectionState(drone: drone!)
    }

    func stopServer() {
        mavsdkServer?.stop()
        serverStarted = false
        isConnected = false
        mavsdkServer = nil
        drone = nil
        systemAddress = nil
        disposeBag = DisposeBag()
    }
    
    func subscribeOnConnectionState(drone: Drone) {
        drone
            .core.connectionState
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (state) in
                self.isConnected = state.isConnected
            })
            .disposed(by: disposeBag)
    }
}
