//
//  MediaView.swift
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 7/30/21.
//

import SwiftUI

struct MediaLibraryView: View {
    @ObservedObject var viewModel = MediaLibraryViewModel()

    var body: some View {
        List {
            Section(header: Text("Media Actions")) {
                ForEach(viewModel.actions, id: \.text) { action in
                    ButtonContent(text: action.text, action: action.action)
                }
            }
            Section(header:
                        HStack{
                            Text("Downloaded Photos")
                            Spacer()
                            Text("\(viewModel.listOfImagesURLStrings.count)")
                        }
            ) {
                ForEach(viewModel.listOfImagesURLStrings, id: \.self) { (urlString) -> ImageView in
                    ImageView(urlString: urlString)
                }
            }
        }
        .font(.system(size: 14, weight: .medium, design: .default))
        .listStyle(PlainListStyle())
    }
}

struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        MediaLibraryView()
    }
}
