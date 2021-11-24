//
//  MainView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

struct MainView: View {
    
    @State var isVideo: Bool = true
    @ObservedObject var mapViewCoordinator = MapViewCoordinator.shared
    
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
                
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack {
                        if !mapViewCoordinator.captureInfoCoordinates.isEmpty {
                            Image(systemName: "square.slash.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .contentShape(Rectangle())
                                .padding(.trailing, 15)
                                .foregroundColor(Color.orange.opacity(0.7))
                                .onTapGesture {
                                    mapViewCoordinator.clearPhotoLocations()
                                }
                        }
                        Image(systemName: "paperplane.circle")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .contentShape(Rectangle())
                            .padding(.trailing, 15)
                            .foregroundColor(Color.green.opacity(0.7))
                            .onTapGesture {
                                mapViewCoordinator.centerMapOnDroneLocation()
                            }
                    }
                    TelemetryDetailView()
                        .padding([.trailing,.bottom], 15)
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
