//
//  CameraSettingsView.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Dmytro Malakhov on 7/16/21.
//

import SwiftUI
import Mavsdk

struct CameraSettingsView: View {
    @ObservedObject var modelView = CameraSettingsViewModel()
    
    var body: some View {
        List(modelView.currentSettings, id: \.settingID) { (setting: Camera.Setting) in
            VStack {
                HStack {
                    Text("\(setting.settingDescription)")
                    Spacer()
                }
                Spacer()
                Menu(content: {
                    CameraSettingsOptionsView(setting: setting, modelView: modelView)
                }, label: {
                    Spacer()
                    Text("\(setting.option.optionDescription)")
                })
            }
        }
        .font(.system(size: 14, weight: .medium, design: .default))
        .listStyle(PlainListStyle())
    }
}

struct CameraSettings_Previews: PreviewProvider {
    static var previews: some View {
        CameraSettingsView()
    }
}
