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
    static var isSimulator = false
    @Published var drone: Drone?
    @Published var systemAddress: String?
    @Published var serverStarted: Bool = false
    @Published var isConnected: Bool = false
    
    private var disposeBag = DisposeBag()
    private var mavsdkServer: MavsdkServer?
    
    func startServer(systemAddress: String) {
        MavsdkDrone.isSimulator = systemAddress.contains("tcp") ? true : false
        self.systemAddress = systemAddress
        mavsdkServer = MavsdkServer()
        let port = mavsdkServer!.run(systemAddress: systemAddress)
        let newDrone = Drone(port: Int32(port))
        _ = newDrone.core.setMavlinkTimeout(timeoutS: 0.5).subscribe()
        serverStarted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { // Delay
            self.drone = newDrone // JONAS | Julian: as soon as we assign newDrone all subscribers will start listen for telemetry updates. If we wont't wait we may never receive position update.
            self.subscribeOnConnectionState(drone: newDrone)
        }
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
            .subscribe(onNext: { [weak self] (state) in
                self?.isConnected = state.isConnected
            })
            .disposed(by: disposeBag)
    }
}
