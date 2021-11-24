//
//  RTSPView.swift
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 2/23/21.
//

import Foundation
import UIKit

class RTSPView: UIImageView {
    private let queue = DispatchQueue(label: "VideoQueue")
    private var isPlaying: Bool = false
    private var player: VideoStreamPlayer? = nil
    private var isBusy: Bool = false
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFit
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func startPlaying(videoPath: String, usesTcp: Bool) {
        isPlaying = true
        timer = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: #selector(RTSPView.update), userInfo: nil, repeats: true)
        
        queue.async { [weak self] in
            self?.player = VideoStreamPlayer(videoPath: videoPath, usesTcp: usesTcp)
        }
    }
    
    func stopPlaying() {
        timer?.invalidate()
        image = nil
        isPlaying = false
        timer = nil
        
        queue.async { [weak self] in
            self?.player = nil
        }
    }
    
    @objc func update(timer: Timer) {
        guard !isBusy else {
            return
        }
        
        isBusy = true
        
        queue.async { [weak self] in
            guard let player = self?.player, player.stepFrame() else {
                return
            }
            
            let currentImage = player.currentImage
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.image = strongSelf.isPlaying ? currentImage : nil
                strongSelf.isBusy = false
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
