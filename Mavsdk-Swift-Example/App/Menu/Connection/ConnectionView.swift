//
//  ConnectionView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/12/21.
//

import SwiftUI

struct ConnectionView: View {
    @ObservedObject var model = ConnectionViewModel()
    @ObservedObject var mavsdk = mavsdkDrone
    @State var connectingToUri: String?
    
    var body: some View {
        List {
            if mavsdk.serverStarted {
                Button("Disconnect")
                {
                    connectingToUri = nil
                    mavsdk.stopServer()
                }
            } else {
                Section(header: Text("Select comm link to connect")) {
                    CommLinkView(name: "Drone", uri: "udp://:14540", connectingToUri: $connectingToUri)
                    CommLinkView(name: "Cloud Sim", uri: "tcp://10.194.41.45:5790", connectingToUri: $connectingToUri)
                }
                if connectingToUri != nil {
                    Section(header: Text("")) {
                        HStack {
                            Spacer()
                            Button("Cancel") {
                                connectingToUri = nil
                                mavsdk.stopServer()
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
