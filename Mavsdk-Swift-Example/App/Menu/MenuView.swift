//
//  MenuView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedTabIndex = 0
    @ObservedObject var mavsdk = mavsdkDrone
    
    var body: some View {
        VStack {
            if mavsdk.serverStarted {
                Picker("Item", selection: $selectedTabIndex, content: {
                    Image(systemName: "arrow.up.arrow.down").tag(0)
                    Image(systemName: "antenna.radiowaves.left.and.right").tag(1)
                    Image(systemName: "play").tag(2)
                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up").tag(3)
                    Image(systemName: "camera").tag(4)
                    Image(systemName: "chevron.up").tag(5)
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            switch selectedTabIndex {
            case 0:
                ConnectionView()
                    .navigationBarTitle("Connection")
            case 1:
                TelemetryView()
                    .navigationBarTitle("Telemetry")
            case 2:
                ActionsView()
                    .navigationBarTitle("Actions")
            case 3:
                MissionsView()
                    .navigationBarTitle("Mission")
            case 4:
                CameraView()
                    .navigationBarTitle("Camera")
            default:
                SiteScanView()
                    .navigationBarTitle("Site Scan")
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
