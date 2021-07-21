//
//  VideoPlayerUIView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 21/05/21.
//

import SwiftUI
import AVKit
import Mavsdk
import MavsdkServer
import RxSwift
import Combine

final class VideoPlayerUIView: UIView {
    static let shared = VideoPlayerUIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    var rtspView: RTSPView!
    let disposeBag = DisposeBag()
    var droneCancellable = AnyCancellable {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isOpaque = false
       
        self.droneCancellable = mavsdkDrone.$isConnected
            .sink {
                if $0 {
                    self.fetchVideoStream()
                } else if self.rtspView != nil {
                    self.rtspView.stopPlaying()
                    self.rtspView = nil
                }
            }
    }
    
    func fetchVideoStream() {
        mavsdkDrone.drone?.camera.videoStreamInfo
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { value in
                print("+DC+ videoStreamInfo \(value)")
                if self.rtspView == nil {
                    self.addVideoFeed(value.settings.uri)
                }
            }, onError: { error in
                print("+DC+ camera videoStreamInfo error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
    }
    
    func addVideoFeed(_ videoPath: String) {
        let newPath = videoPath.replacingOccurrences(of: "rtspt", with: "rtsp")
        rtspView = RTSPView(frame: self.frame)
        
        self.addSubview(rtspView)
        rtspView.translatesAutoresizingMaskIntoConstraints = false
        rtspView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        rtspView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        rtspView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        rtspView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true

        self.rtspView.startPlaying(videoPath: newPath, usesTcp: MavsdkDrone.isSimulator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rtspView?.frame = bounds
    }
}

extension VideoPlayerUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        VideoPlayerUIView.shared.frame = frame
        return VideoPlayerUIView.shared
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
