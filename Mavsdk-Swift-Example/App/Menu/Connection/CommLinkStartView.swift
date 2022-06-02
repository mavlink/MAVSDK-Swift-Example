//
//  CommLinkView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/12/21.
//

import SwiftUI

struct CommLinkStartView: View {
    @ObservedObject var mavsdk = mavsdkDrone
    
    let name: String
    @State var uri: String
    @Binding var connectingToUri: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                TextField("uri", text: $uri)
                    .font(.subheadline)
                    .disabled(connectingToUri != nil)
            }
            Spacer()
            if !mavsdk.serverStarted && connectingToUri == nil {
                Button("Connect") {
                    connectingToUri = uri
                    mavsdkDrone.startServer(systemAddress: uri)
                }
            } else if uri == connectingToUri {
                ProgressView()
            }
        }
    }
}

//struct CommLinkView_Previews: PreviewProvider {
//    @Binding var connectingToUri: String?
//
//    static var previews: some View {
//        List {
//            CommLinkView(name: "Drone", uri: "udp://:14540", connectingToUri: )
//            CommLinkView(name: "Cloud Sim", uri: "tcp://10.194.41.45:5790", connectingToUri: )
//        }
//    }
//}
