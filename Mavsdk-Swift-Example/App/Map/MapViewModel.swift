//
//  MapViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 14/05/21.
//

import Foundation
import RxSwift
import Mavsdk
import Combine
import MapKit


final class MapViewModel: ObservableObject {
    static let shared = MapViewModel()
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    var missionPlanCancellable = AnyCancellable {}
    var droneAnnotation = DroneAnnotation(coordinate: CLLocationCoordinate2D())
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{$0}
            .sink{ [weak self] drone in
                self?.observeDroneLocation(drone: drone)
            }
    }
    
    func observeDroneLocation(drone: Drone) {
        drone.telemetry.position
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (position) in
                self?.droneAnnotation.coordinate = CLLocationCoordinate2D(latitude: position.latitudeDeg, longitude: position.longitudeDeg)
            }, onError: { (error) in
                print("Error in observeDroneLocation: \(error)")
            })
            .disposed(by: disposeBag)
    }
}
