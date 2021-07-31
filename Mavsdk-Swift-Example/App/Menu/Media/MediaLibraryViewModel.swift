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
    let messageViewModel = MessageViewModel.shared
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
        drone.camera.listPhotos(photosRange: .all)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                self?.messageViewModel.message = "Count of photos \(photosRange): \(captureInfoList.count)"
            } onError: { [weak self] (error) in
                self?.messageViewModel.message = "Error get list of \(photosRange) photos: \(error)"
            }
            .disposed(by: disposeBag)

    }
    
    func downloadLastPhoto() {
        drone.camera.listPhotos(photosRange: .all)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                guard !captureInfoList.isEmpty else {
                    self?.messageViewModel.message = "No photos found"
                    return
                }
                self?.listOfImagesURLStrings = [captureInfoList.last!.fileURL]
                self?.messageViewModel.message = "Downloading \(captureInfoList.last!.fileURL)"
            } onError: { [weak self] (error) in
                self?.messageViewModel.message = "Error get list of all photos: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func downloadAllPhotos() {
        drone.camera.listPhotos(photosRange: .all)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                guard !captureInfoList.isEmpty else {
                    self?.messageViewModel.message = "No photos found"
                    return
                }
                self?.listOfImagesURLStrings = captureInfoList.reversed().map{ $0.fileURL }
                self?.messageViewModel.message = "Downloading \(captureInfoList.count) photos"
            } onError: { [weak self] (error) in
                self?.messageViewModel.message = "Error get list of all photos: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func downloadPhotosSinceConnection() {
        drone.camera.listPhotos(photosRange: .sinceConnection)
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] (captureInfoList) in
                guard !captureInfoList.isEmpty else {
                    self?.messageViewModel.message = "No photos found since connection"
                    return
                }
                self?.listOfImagesURLStrings = captureInfoList.reversed().map{ $0.fileURL }
                self?.messageViewModel.message = "Downloading \(captureInfoList.count) photos"
            } onError: { [weak self] (error) in
                self?.messageViewModel.message = "Error get list of photos since connection: \(error)"
            }
            .disposed(by: disposeBag)
    }
    
    func formatStorage() {
        drone.camera.formatStorage()
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] in
                self?.messageViewModel.message = "Storage formatted"
            } onError: { [weak self] (error) in
                self?.messageViewModel.message = "Storage format error: \(error)"
            }
            .disposed(by: disposeBag)
    }
}
