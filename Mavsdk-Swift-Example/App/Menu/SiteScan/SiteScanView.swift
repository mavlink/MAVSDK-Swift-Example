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
            ButtonContent(text: "Subscribe to SS Observers", action: siteScan.subscribeToAllSiteScan)
            ButtonContent(text: "Preflight Check + Takeoff", action: siteScan.preflightCheckListQueue)
        }
        .listStyle(PlainListStyle())
    }
}

struct SiteScanView_Previews: PreviewProvider {
    static var previews: some View {
        SiteScanView()
    }
}
