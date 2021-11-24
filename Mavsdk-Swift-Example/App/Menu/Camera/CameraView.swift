//
//  CameraView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 20/05/21.
//

import SwiftUI

struct CameraView: View {
    
    @ObservedObject var camera = CameraViewModel()
    let cameraSettingsView = CameraSettingsView()
    
    var body: some View {
        List() {
            Section(header: Text("Subscriptions")) {
                InfoRowView(title: "Mode", value: camera.mode)
                InfoRowView(title: "Capture Info", value: camera.captureInfo)
                InfoRowView(title: "Camera specs", value: camera.information)
                InfoRowView(title: "Camera status", value: camera.status)
            }
            Section(header: Text("Camera Setttings")) {
                NavigationLink("Camera Setttings",
                               destination: cameraSettingsView)
                    .isDetailLink(false)
            }
            Section(header: Text("Camera Actions")) {
                ForEach(camera.actions, id: \.text) { action in
                    ButtonContent(text: action.text, action: action.action)
                }
            }
        }
        .font(.system(size: 14, weight: .medium, design: .default))
        .listStyle(PlainListStyle())
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
