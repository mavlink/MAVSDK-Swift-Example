//
//  MissionMenuView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 21/05/21.
//

import SwiftUI

struct MissionMenuView: View {
    
    let missionViewModel = MissionViewModel(missionOperator: MissionOperator.shared)
    @ObservedObject var missionOperator = MissionOperator.shared
    

    var body: some View {
        List {
            Section(header: Text("Missions (Select Mission First)")) {
                ForEach(missionOperator.missions, id: \.title) { mission in
                    VStack {
                        HStack {
                            Text(mission.title)
                            Spacer()
                            if missionOperator.currentMission?.title == mission.title {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            missionOperator.selectMission(mission)
                        }
                    }
                }
                Spacer()
                Button("Center mission to map") {
                    missionOperator.centerToMap()
                }
            }
            Section(header: Text("Actions")) {
                ForEach(missionViewModel.actions, id: \.text) { action in
                    ButtonContent(text: action.text, action: action.action)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct MissionView_Previews: PreviewProvider {
    static var previews: some View {
        MissionMenuView()
    }
}
