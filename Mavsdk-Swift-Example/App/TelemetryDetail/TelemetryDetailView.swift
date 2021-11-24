//
//  TelemetryDetailView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 17/05/21.
//

import SwiftUI

struct TelemetryDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var expanded = false
    @ObservedObject var telemetry = TelemetryDetailViewModel()
    @ObservedObject var messageViewModel = MessageViewModel.shared
    
    var body: some View {
        if expanded {
            VStack(alignment: .trailing) {
                HStack {
                    ExpandViewButton(expanded: $expanded)
                    Spacer()
                }
                List(messageViewModel.allMessages) { logRecord in
                    HStack(alignment: VerticalAlignment.top) {
                        Text(string(from: logRecord.date))
                        Text(logRecord.message)
                            .fontWeight(.light)
                    }
                }
            }
            .background(colorScheme == .dark ? Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 0.9501284247)) : Color(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.95)))
            .cornerRadius(10.0)
        } else {
            VStack {
                HStack(alignment: .top) {
                    ExpandViewButton(expanded: $expanded)
                    TelemetryInfo(value: "\(telemetry.altitude)m", title: "current altitude")
                    TelemetryInfo(value: "\(telemetry.battery)%", title: "battery level")
                    TelemetryInfo(value: "\(telemetry.photosTaken)", title: "images")
                    TelemetryInfo(value: "\(Int(telemetry.missionProgressCurrent))/\(Int(telemetry.missionProgressTotal))", title: "mission progress")
                }
                Text(messageViewModel.message)
                    .padding(.bottom)
            }
            .background(colorScheme == .dark ? Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 0.9501284247)) : Color(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.95)))
            .cornerRadius(10.0)
        }
        
    }
    
    func string(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: date)
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

struct ExpandViewButton: View {
    @Binding var expanded: Bool
    
    var body: some View {
        Image(systemName: expanded ? "arrow.down.forward.and.arrow.up.backward" : "arrow.up.backward.and.arrow.down.forward")
            .font(.system(size: 16.0, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
            .padding()
            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            .contentShape(Rectangle())
            .onTapGesture {
                expanded.toggle()
            }
    }
}
