//
//  ActionsView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI

struct ActionsView: View {
    var action = ActionsViewModel()
    
    var body: some View {
        List(action.actions, id: \.text) { action in
            ButtonContent(text: action.text, action: action.action)
        }
        .listStyle(PlainListStyle())
    }
}

struct ActionList_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView()
    }
}

struct ButtonContent: View {
    @State var text: String
    @State var action: () -> ()
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: action, label: {
                Text(text)
                    .font(.system(size: 14, weight: .medium, design: .default))
            })
            Spacer()
        }
        .padding()
    }
}
