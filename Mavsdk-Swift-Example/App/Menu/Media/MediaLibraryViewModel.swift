//
//  MediaViewModel.swift
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 7/30/21.
//

import Foundation
import Combine
import RxSwift
import Mavsdk


class MediaLibraryViewModel: ObservableObject {
    @Published var listOfImagesURLStrings = [String]()
    
    let drone = mavsdkDrone.drone!
    let disposeBag = DisposeBag()
    
    var actions: [Action] {
        return [
            Action(text: "Fetch list of all photos", action: { self.fetchListOfPhotos(photosRange: .all) }),
            Action(text: "Fetch list of photos since connection", action: { self.fetchListOfPhotos(photosRange: .sinceConnection) }),
            Action(text: "Download last photo", action: downloadLastPhoto ),
            Action(text: "Download all photos", action: downloadAllPhotos ),
            Action(text: "Download photos taken since connection", action: downloadPhotosSinceConnection ),
            Action(text: "Format storage", action: formatStorage )
        ]
    }
    
    func fetchListOfPhotos(photosRange: Camera.PhotosRange) {
        drone.camera.listPhotos(photosRange: photosRange)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { (captureInfoList) in
                MessageViewModel.shared.message = "Count of photos \(photosRange): \(captureInfoList.count)"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error get list of \(photosRange) photos: \(error)"
            }
            .disposed(by: disposeBag)

    }
    
    func downloadLastPhoto() {
        drone.camera.listPhotos(photosRange: .all)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                guard !captureInfoList.isEmpty else {
                    MessageViewModel.shared.message = "No photos found"
                    return
                }
                self?.listOfImagesURLStrings = [captureInfoList.last!.fileURL]
                MessageViewModel.shared.message = "Downloading \(captureInfoList.last!.fileURL)"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error get list of all photos: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func downloadAllPhotos() {
        drone.camera.listPhotos(photosRange: .all)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                guard !captureInfoList.isEmpty else {
                    MessageViewModel.shared.message = "No photos found"
                    return
                }
                self?.listOfImagesURLStrings = captureInfoList.reversed().map{ $0.fileURL }
                MessageViewModel.shared.message = "Downloading \(captureInfoList.count) photos"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error get list of all photos: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func downloadPhotosSinceConnection() {
        drone.camera.listPhotos(photosRange: .sinceConnection)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                guard !captureInfoList.isEmpty else {
                    MessageViewModel.shared.message = "No photos found since connection"
                    return
                }
                self?.listOfImagesURLStrings = captureInfoList.reversed().map{ $0.fileURL }
                MessageViewModel.shared.message = "Downloading \(captureInfoList.count) photos"
            } onError: { (error) in
                MessageViewModel.shared.message = "Error get list of photos since connection: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func formatStorage() {
        drone.camera.formatStorage()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe {
                MessageViewModel.shared.message = "Storage formatted"
            } onError: { (error) in
                MessageViewModel.shared.message = "Storage format error: \(error)"
            }
            .disposed(by: disposeBag)
    }
}
