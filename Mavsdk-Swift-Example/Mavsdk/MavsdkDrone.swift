//
//  MavsdkDrone.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import Foundation
import Mavsdk
import RxSwift

let MavScheduler = ConcurrentDispatchQueueScheduler(qos: .default)

class MavsdkDrone: ObservableObject {
    static var isSimulator = false
    @Published var drone: Drone?
    @Published var systemAddress: String?
    @Published var serverStarted: Bool = false
    @Published var isConnected: Bool = false
    
    private var disposeBag = DisposeBag()

    func startServer(systemAddress: String) {
        MavsdkDrone.isSimulator = systemAddress.contains("tcp") ? true : false
        let newDrone = Drone()
        self.systemAddress = systemAddress
        newDrone.connect(systemAddress: systemAddress)
            .subscribe(on: MavScheduler)
            .observe(on: MainScheduler.instance)
            .do(onCompleted: {  [weak self] in
                self?.serverStarted = true
                self?.drone = newDrone
                self?.subscribeOnConnectionState(drone: newDrone)
            })
            .andThen(Observable<Any>.never()) // So that it does not dispose automatically onComplete
            .subscribe(onDisposed: {
                newDrone.disconnect()
            })
            .disposed(by: disposeBag)
    }

    func stopServer() {
        disposeBag = DisposeBag()
        serverStarted = false
        isConnected = false
        drone = nil
        systemAddress = nil
    }

    func connectToServer(serverAddress: String, serverPort: Int32 = 50051) {
        let newDrone = Drone()
        newDrone.connect(mavsdkServerAddress: serverAddress, mavsdkServerPort: serverPort)
            .subscribe(on: MavScheduler)
            .observe(on: MainScheduler.instance)
            .do(onCompleted: { [weak self] in
                self?.serverStarted = true
                self?.drone = newDrone
                self?.subscribeOnConnectionState(drone: newDrone)
            })
            .andThen(Observable<Any>.never()) // So that it does not dispose automatically
            .subscribe(onDisposed: {
                newDrone.disconnect()
            })
            .disposed(by: disposeBag)
    }
    
    func subscribeOnConnectionState(drone: Drone) {
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
