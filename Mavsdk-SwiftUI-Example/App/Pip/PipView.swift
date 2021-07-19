//
//  PipView.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

struct PipView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mavsdk = mavsdkDrone
    
    @Binding var isVideo: Bool
    
    var body: some View {
        VStack(alignment: .leading) {

            ZStack {
                if isVideo {
                    VideoView()
                } else {
                    MapView()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isVideo.toggle()
                        }, label: {
                            Image(systemName: "arrow.up.backward.and.arrow.down.forward")
                                .font(.system(size: 16.0, weight: .semibold, design: .monospaced))
                                .rotationEffect(.init(degrees: 90))
                                .foregroundColor(.white)
                                .padding(.all, 10)
                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                        })
                    }
                    Spacer()
                }
            }

            HStack {
              Image(systemName: "circlebadge.fill")
                .foregroundColor(mavsdk.isConnected ? .green : Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.75)) )
                Text(mavsdk.isConnected ? "Connected" : "Disconnected")
                    .font(.system(size: 16.0, weight: .semibold, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.all, 12)
            .onTapGesture {
                isVideo.toggle()
            }
        }
        .background(colorScheme == .dark ? Color(#colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 0.9501284247)) : Color(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.95)))
        .cornerRadius(10.0)
    }
}

struct PipView_Previews: PreviewProvider {
    static var previews: some View {
        PipView(isVideo: .constant(true))
            .previewLayout(.fixed(width: 204, height: 180))
    }
}
