//
//  Mavsdk_SwiftUI_ExampleApp.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

var mavsdkDrone = MavsdkDrone()

@main
struct Mavsdk_SwiftUI_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
