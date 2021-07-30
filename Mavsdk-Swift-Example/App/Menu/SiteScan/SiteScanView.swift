//
//  SiteScanView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 20/05/21.
//

import SwiftUI

struct SiteScanView: View {
    let siteScan = SiteScanViewModel()
    
    var body: some View {
        List {
            ButtonContent(text: "Subscribe to SiteScan Observers", action: siteScan.subscribeToAllSiteScan)
            ButtonContent(text: "Upload mission test", action: siteScan.uploadMission)
        }
        .listStyle(PlainListStyle())
    }
}

struct SiteScanView_Previews: PreviewProvider {
    static var previews: some View {
        SiteScanView()
    }
}
