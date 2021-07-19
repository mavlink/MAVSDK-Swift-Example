//
//  TelemetryDetailView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 17/05/21.
//

import SwiftUI

struct TelemetryDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var telemetry = TelemetryDetailViewModel()
    @ObservedObject var messageViewModel = MessageViewModel.shared
    
    var body: some View {
        VStack {
            HStack {
                TelemetryInfo(value: "\(telemetry.altitude)m", title: "current altitude")
                TelemetryInfo(value: "\(telemetry.battery)%", title: "battery level")
                TelemetryInfo(value: "\(telemetry.photosTaken)", title: "images")
                
            }
            Text(messageViewModel.message)
                .padding(.bottom)
        }
        .background(colorScheme == .dark ? Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 0.9501284247)) : Color(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.95)))
        .cornerRadius(10.0)
    }
}

struct TelemetryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TelemetryDetailView()
    }
}

struct TelemetryInfo: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.system(size: 26.0, weight: .semibold, design: .monospaced))
            Text(title)
                .font(.system(size: 10.0, weight: .medium, design: .default))
        }
        .padding()
    }
}
