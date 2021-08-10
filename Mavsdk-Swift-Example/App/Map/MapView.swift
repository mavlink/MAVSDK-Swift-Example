//
//  MapView.swift
//  Mavsdk-Swift-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI
import MapKit
import Combine


struct MapView: UIViewRepresentable {
    static let mapZoomEdgeInsets = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator.shared
    }
    
    func makeUIView(context: Context) -> MKMapView {
        return context.coordinator.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {

    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
