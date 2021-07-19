//
//  ConnectionView.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Dmytro Malakhov on 7/12/21.
//

import SwiftUI

struct ConnectionView: View {
    @ObservedObject var model = ConnectionViewModel()
    @ObservedObject var mavsdk = mavsdkDrone
    
    var body: some View {
        List {
            if mavsdk.serverStarted {
                Button("Stop Mavsdk server")
                {
                    mavsdk.stopServer()
                }
            } else {
                Section(header: Text("Select comm link to connect")) {
                    CommLinkView(name: "Drone", uri: "udp://:14540")
                    CommLinkView(name: "Cloud Sim", uri: "tcp://3.236.239.1:5790")
                    CommLinkView(name: "Cloud Sim #2", uri: "tcp://3.239.76.218:5790")
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
