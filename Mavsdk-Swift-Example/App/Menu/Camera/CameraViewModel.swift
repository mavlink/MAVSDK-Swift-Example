//
//  CameraViewModel.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 20/05/21.
//

import Foundation
import RxSwift
import Combine
import Mavsdk

final class CameraViewModel: ObservableObject {
    @Published private(set) var captureInfo = "N/A"
    @Published private(set) var mode = "N/A"
    @Published private(set) var information = "N/A"
    @Published private(set) var status = "N/A"
    
    var drone: Drone!
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}
    
    var actions: [Action] {
        return [
            Action(text: "Set Photo Mode", action: setPhotoMode),
            Action(text: "Set Video Mode", action:setVideoMode),
            Action(text: "Take Photo", action: takePhoto),
            Action(text: "Start Taking Photos", action: starTakingPhotos),
            Action(text: "Stop Taking Photos", action: stopTakingPhotos),
            Action(text: "Start Video Recording", action: startVideo),
            Action(text: "Stop Video Recoding", action: stopVideo),
            Action(text: "List of Photos", action: getListOfPhotos),
            Action(text: "Format Storage", action: formatStorage),
            Action(text: "Start Video Streaming", action: startVideoStreaming),
            Action(text: "Stop Video Streaming", action: stopVideoStreaming)
        ]
    }
    
    init() {
        self.droneCancellable = mavsdkDrone.$drone.compactMap{$0}
            .sink{ [weak self] drone in
                self?.drone = drone
                self?.observeCamera(drone: drone)
            }
    }
    
    func observeCamera(drone: Drone) {
        drone.camera.captureInfo
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (captureInfo) in
                let message = "isSuccess:\(captureInfo.isSuccess), index:\(captureInfo.index)\nurl:\(captureInfo.fileURL)"
                self?.captureInfo = message
                MessageViewModel.shared.message = message
            })
            .disposed(by: disposeBag)
        
        drone.camera.mode
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (mode) in
                self?.mode = String(describing: mode)
            })
            .disposed(by: disposeBag)
        
        drone.camera.information
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (information) in
                self?.information = "\(information.vendorName),\(information.modelName)\nfocalLength:\(information.focalLengthMm), \(information.verticalResolutionPx)/\(information.horizontalResolutionPx)"
            })
            .disposed(by: disposeBag)
        
        drone.camera.status
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (status) in
                self?.status = "photoIntervalOn:\(status.photoIntervalOn), videoOn:\(status.videoOn)\nused/total Mib:\(status.usedStorageMib)/\(status.totalStorageMib)\n recordingTime:\(status.recordingTimeS)\nstorageStatus:\(String(describing: status.storageStatus))"
            })
            .disposed(by: disposeBag)
    }
    
    func setPhotoMode() {
        drone.camera.setMode(mode: .photo)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Set to Photo Mode"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Setting Photo Mode: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func setVideoMode() {
        drone.camera.setMode(mode: .video)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Set to Video Mode"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Setting Video Mode: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func takePhoto() {
        drone.camera.takePhoto()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Photo Taken"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Taking Photo: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func starTakingPhotos() {
        drone.camera.startPhotoInterval(intervalS: 2.0)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Start Taking Photos with 2 sec interval"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Starting Photo Interval: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func stopTakingPhotos() {
        drone.camera.stopPhotoInterval()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Stop Taking Photos"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Stopping Photo Interval: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func startVideo() {
        drone.camera.startVideo()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Start Video Recording"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Starting Video Recording: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func stopVideo() {
        drone.camera.stopVideo()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Stop Video Recording"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Stopping Video Recording: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func getListOfPhotos() {
        drone.camera.listPhotos(photosRange: .all)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { (captureInfo) in
                MessageViewModel.shared.message = "List Count \(captureInfo.count)"
            }, onError: { (error) in
                MessageViewModel.shared.message = "Error Getting List: \(error)"
            },  onSubscribe: {
                MessageViewModel.shared.message = "Getting List of Photos"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func formatStorage() {
        drone.camera.formatStorage()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Format Storage"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Formatting Storage: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func startVideoStreaming() {
        drone.camera.startVideoStreaming()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Start Video Streaming"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Starting Video Streaming: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func stopVideoStreaming() {
        drone.camera.stopVideoStreaming()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Stop Video Streaming"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error Stopping Video Streaming: \(error)"
            }
            .disposed(by: disposeBag)
    }
}
