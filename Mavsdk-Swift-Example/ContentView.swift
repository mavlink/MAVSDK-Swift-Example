//
//  MainView.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

struct MainView: View {
    
    @State var isVideo: Bool = true
    
    var body: some View {
        NavigationView {
            MenuView()
            ZStack(alignment: .topTrailing) {
                
                if isVideo {
                    MapView()
                } else {
                    VideoView()
                }

                PipView(isVideo: $isVideo.animation())
                    .frame(width: 204, height: 180)
                    .padding(.top, 32)
                    .padding(.trailing, 16)
                
                VStack {
                    Spacer()
                    TelemetryDetailView()
                        .padding()
                }
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
