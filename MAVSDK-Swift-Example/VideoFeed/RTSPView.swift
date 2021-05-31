//
//  RTSPView.swift
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 2/23/21.
//

import Foundation
import UIKit


class RTSPView: UIImageView {

    var isPlaying: Bool = false
    private var player: VideoStreamPlayer? = nil
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFit
    }
    
    func startPlaying(videoPath: String, usesTcp: Bool) {
        isPlaying = true
        
        player = VideoStreamPlayer(videoPath: videoPath, usesTcp: usesTcp)
        player?.outputWidth = Int32(frame.width)
        player?.outputHeight = Int32(frame.height)
        timer = Timer.scheduledTimer(timeInterval: 1.0/40, target: self, selector: #selector(RTSPView.update), userInfo: nil, repeats: true)
    }
    
    func stopPlaying() {
        timer?.invalidate()
        player = nil
        image = nil
        isPlaying = false
    }
    
    @objc func update(timer: Timer) {
        guard let player = player, player.stepFrame() else {
            stopPlaying()
            return
        }
        
        image = player.currentImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
