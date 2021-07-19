//
//  MapView.swift
//  Mavsdk-SwiftUI-Example
//
//  Created by Douglas on 13/05/21.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mapViewModel = MapViewModel()
    
    let places = [
        Location(latitude: 37.413416, longitude: -121.998232, angle: 0.0)
    ]
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.413416, longitude: -121.998232), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: [mapViewModel.droneLocation]) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .frame(width: 26.0, height: 26.0)
                        .foregroundColor(colorScheme == .dark ? Color(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        .rotationEffect(.degrees(item.angle))
                }
            }
        }
    }
}
