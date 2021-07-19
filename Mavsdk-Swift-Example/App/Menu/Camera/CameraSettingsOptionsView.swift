//
//  CameraSettingsOptionsView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/16/21.
//

import SwiftUI
import Mavsdk

struct CameraSettingsOptionsView: View {
    
    let setting: Camera.Setting
    let modelView: CameraSettingsViewModel
    var options: [Camera.Option] {
        modelView.settingOptions(setting)?.options ?? []
    }
    
    var body: some View {
        if options.isEmpty {
            Text("No options for setting \(setting.settingDescription) 😢")
        }
        
        ForEach(options, id: \.optionID) { option in
            Button(option.optionDescription) {
                modelView.setCameraSetting(setting, option: option)
            }
        }
    }
}

struct CameraSettingsOptionsView_Previews: PreviewProvider {
    static let setting = Camera.Setting(settingID: "1",
                                 settingDescription: "testSetting",
                                 option: Camera.Option(optionID: "1",
                                                       optionDescription: "testOption"),
                                 isRange: false)
    
    static var previews: some View {
        CameraSettingsOptionsView(setting: setting,
                                  modelView: CameraSettingsViewModel())
    }
}
