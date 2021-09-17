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

private class CaptureInfoCircle: MKCircle {}
private class MissionWaypointCircle: MKCircle {}

final class MapViewCoordinator: NSObject, MKMapViewDelegate, ObservableObject {
    static let shared = MapViewCoordinator()
    let mapView = MKMapView()
    let missionOperator = MissionOperator.shared
    private var cancelables = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()
    
    private var missionPlanCoordinates: [CLLocationCoordinate2D] = [] {
        didSet {
            updateMissionPlanOverlay()
            updateMissionPlanTitleAnnotation()
        }
    }
    @Published private(set) var captureInfoCoordinates: [CLLocationCoordinate2D] = [] {
        didSet {
            updateCaptureInfoOverlay()
        }
    }
    
    // Overlays
    private var missionPlanOverlays = [MKOverlay]()
    private var captureInfoOverlays = [MKOverlay]()
    
    // Annotations
    private var missionPlanTitleAnnotation: MissionMapTitleAnnotation?
    private var droneAnnotation: DroneAnnotation?
    
    override init() {
        super.init()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        subscribeOnMissionUpdates()
        setMapZoomArea(polyline: MKPolyline(coordinates: &missionOperator.mapCenterCoordinate, count: 1))
        
        mavsdkDrone.$drone.compactMap{$0}
            .sink{ [weak self] in
                self?.observeMavsdkUpdates(drone: $0)
            }
            .store(in: &cancelables)
    }
    
    func clearPhotoLocations() {
        captureInfoCoordinates = []
    }
    
    func centerMapOnDroneLocation() {
        if let coordinate = droneAnnotation?.coordinate {
            withUnsafePointer(to: coordinate) { coordinatePointer in
                setMapZoomArea(polyline: MKPolyline(coordinates: coordinatePointer, count: 1))
            }
        }
    }
    
    func observeMavsdkUpdates(drone: Drone) {
        drone.telemetry.position
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (position) in
                self?.updateDroneAnnotation(coordinate: CLLocationCoordinate2D(latitude: position.latitudeDeg, longitude: position.longitudeDeg))
            })
            .disposed(by: disposeBag)
        
        drone.camera.captureInfo
            .subscribeOn(MavScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (captureInfo) in
                self?.captureInfoCoordinates.append(CLLocationCoordinate2D(latitude: captureInfo.position.latitudeDeg, longitude: captureInfo.position.longitudeDeg))
            }, onError: { (error) in
                print("Error in captureInfo: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func subscribeOnMissionUpdates() {
        missionOperator.$missionPlanCoordinates.sink { [weak self] (locations) in
            self?.missionPlanCoordinates = locations
        }
        .store(in: &cancelables)
    }
    
    func updateDroneAnnotation(coordinate: CLLocationCoordinate2D?) {
        if let droneCoordinate = coordinate {
            if let droneAnnotation = droneAnnotation {
                droneAnnotation.coordinate = droneCoordinate
            } else {
                droneAnnotation = DroneAnnotation(coordinate: droneCoordinate)
                mapView.addAnnotation(droneAnnotation!)
            }
        } else {
            if let droneAnnotation = droneAnnotation {
                mapView.removeAnnotation(droneAnnotation)
            }
        }
    }
    
    func updateMissionPlanTitleAnnotation() {
        if let missionTitleCoordinate = missionPlanCoordinates.first {
            if let missionPlanTitleAnnotation = missionPlanTitleAnnotation {
                missionPlanTitleAnnotation.coordinate = missionTitleCoordinate
            } else {
                missionPlanTitleAnnotation = MissionMapTitleAnnotation(coordinate: missionTitleCoordinate)
                mapView.addAnnotation(missionPlanTitleAnnotation!)
            }
        } else {
            if let missionPlanTitleAnnotation = missionPlanTitleAnnotation {
                mapView.removeAnnotation(missionPlanTitleAnnotation)
            }
        }
    }
    
    func updateCaptureInfoOverlay() {
        mapView.removeOverlays(captureInfoOverlays)
        captureInfoOverlays = []

        for location in captureInfoCoordinates {
            let point = CaptureInfoCircle(center: location, radius: 0.3)
            mapView.addOverlay(point)
            captureInfoOverlays.append(point)
        }
    }
    
    func updateMissionPlanOverlay() {
        mapView.removeOverlays(missionPlanOverlays)
        missionPlanOverlays = []

        if !missionPlanCoordinates.isEmpty {
            let polyline = MKPolyline(coordinates: missionPlanCoordinates, count: missionPlanCoordinates.count)
            mapView.addOverlay(polyline)
            missionPlanOverlays.append(polyline)

            for location in missionPlanCoordinates {
                let point = MissionWaypointCircle(center: location, radius: 0.5)
                mapView.addOverlay(point)
                missionPlanOverlays.append(point)
            }

            setMapZoomArea(polyline: polyline)
        }
    }
    
    func setMapZoomArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets = MapView.mapZoomEdgeInsets, animated: Bool = true) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
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
        case is MissionWaypointCircle:
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeStart = 0
            renderer.strokeEnd = 1
            renderer.strokeColor = .systemBlue.withAlphaComponent(0.3)
            return renderer
        case is CaptureInfoCircle:
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeStart = 0
            renderer.strokeEnd = 1
            renderer.strokeColor = .orange.withAlphaComponent(0.4)
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

