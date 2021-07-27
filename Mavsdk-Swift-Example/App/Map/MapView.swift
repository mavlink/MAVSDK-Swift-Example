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
    @ObservedObject var missionOperator = MissionOperator.shared
    @ObservedObject var mapViewModel = MapViewModel.shared
    private let mapZoomEdgeInsets = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
    
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        setMapZoomArea(map: mapView,
                       polyline: MKPolyline(coordinates: &missionOperator.mapCenterCoordinate, count: 1),
                       edgeInsets: mapZoomEdgeInsets,
                       animated: true)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        updateOverlays(from: uiView)
        updateAnnotations(from: uiView)
    }
    
    func updateOverlays(from mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        let locations = missionOperator.missionPlanCoordinates
        
        guard !locations.isEmpty else {
            return
        }
        
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        mapView.addOverlay(polyline)
        
        for location in locations {
            let point = MKCircle(center: location, radius: 0.5)
            mapView.addOverlay(point)
        }
        
        setMapZoomArea(map: mapView, polyline: polyline, edgeInsets: mapZoomEdgeInsets, animated: true)
    }
    
    func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        let droneAnnotation = mapViewModel.droneAnnotation
        mapView.addAnnotation(droneAnnotation)
        
        let missionTitleAnnotation = MissionMapTitleAnnotation(coordinate: missionOperator.startCoordinate)
        mapView.addAnnotation(missionTitleAnnotation)
    }
    
    func setMapZoomArea(map: MKMapView, polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        map.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
