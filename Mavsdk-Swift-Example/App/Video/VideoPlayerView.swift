//
//  VideoPlayerView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas Silva on 17/06/21.
//

import Foundation
import SwiftUI

// Convert UIKit view into SwiftUI view.
struct VideoPlayerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        PlayerUIView.shared.frame = frame
        return PlayerUIView.shared
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
