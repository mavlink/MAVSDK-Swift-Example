//
//  MissionView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 21/05/21.
//

import SwiftUI

struct MissionView: View {
    
    var mission = MissionViewModel()
    
    var body: some View {
        List(mission.actions, id: \.text) { action in
            ButtonContent(text: action.text, action: action.action)
        }
        .listStyle(PlainListStyle())
    }
}

struct MissionView_Previews: PreviewProvider {
    static var previews: some View {
        MissionView()
    }
}
