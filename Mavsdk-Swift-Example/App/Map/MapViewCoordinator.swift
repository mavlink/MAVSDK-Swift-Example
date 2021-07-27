//
//  MapViewCoordinator.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/20/21.
//

import MapKit
import Combine
import Mavsdk
import RxSwift


final class MapViewCoordinator: NSObject, MKMapViewDelegate {
    private let map: MapView
    private let missionOperator = MissionOperator.shared
    
    init(_ control: MapView) {
        self.map = control
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is DroneAnnotation:
            return DroneAnnotationView(annotation: annotation)
        case is MissionMapTitleAnnotation:
            return MissionMapTitleAnnotationView(annotation: annotation)
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3.0
            return renderer
        case is MKCircle:
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeStart = 0
            renderer.strokeEnd = 1
            renderer.strokeColor = .systemBlue
            return renderer
        default:
            let renderer = MKOverlayRenderer(overlay: overlay)
            return renderer
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        missionOperator.mapCenterCoordinate = mapView.centerCoordinate
    }
}

