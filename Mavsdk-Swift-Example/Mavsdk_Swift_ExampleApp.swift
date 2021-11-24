//
//  Mavsdk_Swift_ExampleApp.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

var mavsdkDrone = MavsdkDrone()

@main
struct Mavsdk_Swift_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
