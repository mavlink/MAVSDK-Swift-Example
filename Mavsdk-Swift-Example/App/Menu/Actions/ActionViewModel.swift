//
//  ActionViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 14/05/21.
//

import Foundation
import Mavsdk
import RxSwift

final class ActionViewModel: ObservableObject {
    lazy var drone = mavsdkDrone.drone
    let messageViewModel = MessageViewModel.shared
    let disposeBag = DisposeBag()
    
    var actions: [Action] {
        return [
            Action(text: "Arm", action: armAction),
            Action(text: "Disarm", action: disarmAction),
            Action(text: "TakeOff", action: takeOffAction),
            Action(text: "Land", action: landAction),
            Action(text: "RTL", action: rtlAction),
            Action(text: "Set RTL Altitude", action: setRTLAltitude)
        ]
    }
    
    init() {}
    
    func armAction() {
        drone!.action.arm()
            .subscribe {
                self.messageViewModel.message = "Armed Success"
            } onError: { (error) in
                self.messageViewModel.message = "Error Arming: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func disarmAction() {
        drone!.action.disarm()
            .subscribe {
                self.messageViewModel.message = "Disarmed Success"
            } onError: { (error) in
                self.messageViewModel.message = "Error Disarming: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func takeOffAction() {
        drone!.action.takeoff()
            .subscribe {
                self.messageViewModel.message = "Taking Off Success"
            } onError: { (error) in
                self.messageViewModel.message = "Error Taking Off: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func landAction() {
        drone!.action.land()
            .subscribe {
                self.messageViewModel.message = "Landing Success"
            } onError: { (error) in
                self.messageViewModel.message = "Error Landing: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func rtlAction() {
        drone!.action.returnToLaunch()
            .subscribe {
                self.messageViewModel.message = "RTL Success"
            } onError: { (error) in
                self.messageViewModel.message = "Error RTL: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func setRTLAltitude() {
        drone!.action.setReturnToLaunchAltitude(relativeAltitudeM: 40)
            .subscribe(onCompleted: {
                self.messageViewModel.message = "Set RTL Altitude 40m Success"
            }, onError: { (error) in
                self.messageViewModel.message = "Error Setting RTL Altitude: \(error)"
            })
            .disposed(by: disposeBag)
    }
}
