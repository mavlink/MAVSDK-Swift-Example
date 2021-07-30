//
//  CommLinkView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/12/21.
//

import SwiftUI

struct CommLinkView: View {
    @ObservedObject var mavsdk = mavsdkDrone
    
    let name: String
    let uri: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(uri)
                    .font(.subheadline)
            }
            Spacer()
            if !mavsdk.serverStarted {
                Button("Connect") {
                    mavsdkDrone.startServer(systemAddress: uri)
                }
            } else if uri == mavsdk.systemAddress {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
    }
}

struct CommLinkView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CommLinkView(name: "Cloud Sim", uri: "tcp://44.192.80.108:5790")
            CommLinkView(name: "Drone", uri: "udp://:14540")
        }
    }
}
