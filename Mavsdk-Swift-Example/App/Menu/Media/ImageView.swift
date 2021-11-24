//
//  ImageView.swift
//  MAVSDK_Swift_Example
//
//  Created by Dmytro Malakhov on 7/30/21.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var imageViewModel: ImageViewModel
    @State private var isPresented = false
    let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        self.imageViewModel = ImageViewModel(urlString: urlString)
    }

    var body: some View {
        VStack {
            if imageViewModel.image != nil {
                ZStack(alignment: .bottom) {
                    Image(uiImage: imageViewModel.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text(urlString)
                }
            } else if imageViewModel.error != nil {
                Text(urlString)
                Text(imageViewModel.error!)
                    .foregroundColor(Color.red)
            } else {
                HStack {
                    ProgressView()
                    Text(urlString)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented.toggle()
        }
        .fullScreenCover(isPresented: $isPresented) {
            ZStack {
                Image(uiImage: imageViewModel.image ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .pinchToZoom()
                HStack(alignment: .top) {
                    VStack {
                        Image(systemName: "xmark")
                            .padding(15)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isPresented.toggle()
                            }
                        Spacer()
                    }
                    Spacer()
                    Text(urlString)
                        .background(Color.gray)
                }
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(urlString: "https://i2.wp.com/auterion.com/wp-content/uploads/2020/10/auterion-esri.png")
            .frame(width: 300)
    }
}
