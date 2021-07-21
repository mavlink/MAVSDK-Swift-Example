//
//  VideoView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 14/05/21.
//

import SwiftUI

struct VideoView: View {
    @ObservedObject var mavsdk = mavsdkDrone
    
    var body: some View {
        ZStack {
            Color.gray
            if mavsdk.isConnected {
                ProgressView()
            }
            VideoPlayerView()
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}
