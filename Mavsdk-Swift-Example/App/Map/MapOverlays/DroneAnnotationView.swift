//
//  DroneAnnotationView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/26/21.
//

import Foundation
import MapKit
import Combine
import Mavsdk
import RxSwift


class DroneAnnotationView: MKAnnotationView {
    let disposeBag = DisposeBag()

    init(annotation: MKAnnotation?) {
        super.init(annotation: annotation, reuseIdentifier: "drone")

        image = UIImage(named: "drone")
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        mavsdkDrone.drone!.telemetry.attitudeEuler
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (angle) in
                self?.transform = CGAffineTransform(rotationAngle: CGFloat(angle.yawDeg) * .pi / 180)
            }, onError: { (error) in
                print("Error in attitudeEuler: \(error)")
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
