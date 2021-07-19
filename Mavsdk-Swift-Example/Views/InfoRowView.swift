//
//  InfoRowView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/16/21.
//

import SwiftUI

struct InfoRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
            }
            Spacer()
            HStack {
                Spacer()
                Text(value)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct InfoRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                InfoRowView(title: "Location", value: "altitude:12.3\nlat:45.1234567, long:-122.1234567")
                InfoRowView(title: "Location", value: "lat:45.1234567, long:-122.1234567\naltitude:123.43")
            }
        }
        .previewDevice("iPhone 8")
        
    }
}
