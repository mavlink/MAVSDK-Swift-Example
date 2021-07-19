//
//  TelemetryView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 14/05/21.
//

import SwiftUI


struct TelemetryView: View {
    @EnvironmentObject var mavsdkDrone: MavsdkDrone
    @ObservedObject var telemetryViewModel = TelemetryViewModel()
    
    var body: some View {
        List {
            InfoRowView(title: "Flight Mode", value: telemetryViewModel.flightMode)
            InfoRowView(title: "Armed", value: telemetryViewModel.armed)
            InfoRowView(title: "Location", value: telemetryViewModel.droneCoordinate)
            InfoRowView(title: "Altitude", value: telemetryViewModel.droneAltitude)
            InfoRowView(title: "Attitude", value: telemetryViewModel.attitudeEuler)
            InfoRowView(title: "Camera Attitude", value: telemetryViewModel.cameraAttitudeEuler)
            InfoRowView(title: "GPS Info", value: telemetryViewModel.gpsInfo)
            InfoRowView(title: "Landed State", value: telemetryViewModel.landedState)
        }
        .font(.system(size: 14, weight: .medium, design: .default))
        .listStyle(PlainListStyle())
    }
}

struct TelemetryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TelemetryView()
                .previewLayout(.fixed(width: 896, height: 100))
        }
    }
}
