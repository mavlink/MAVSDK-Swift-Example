import SwiftUI

struct CommLinkConnectView: View {
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
                    mavsdkDrone.connectToServer(serverAddress: uri)
                }
            } else if uri == connectingToUri {
                ProgressView()
            }
        }
    }
}
