import UIKit
import Dronecode_SDK_Swift
import MapKit
import RxSwift

class MapViewController: UIViewController, CLLocationManagerDelegate {

    var disposeBag = DisposeBag()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var uploadMissionButton: UIButton!
    @IBOutlet weak var cancelUploadMissionButton: UIButton!
    @IBOutlet weak var startMissionButton: UIButton!
    @IBOutlet weak var pauseMissionButton: UIButton!
    @IBOutlet weak var setCurrentIndexButton: UIButton!
    @IBOutlet weak var downloadMissionButton: UIButton!
    @IBOutlet weak var isMissionFinishedButton: UIButton!

    @IBOutlet weak var createFlightPathButton: UIButton!
    @IBOutlet weak var centerMapOnDroneButton: UIButton!

    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    let regionRadius: CLLocationDistance = 100

    private var droneAnnotation = NamedAnnotation(title: "Drone")

    private let mission = ExampleMission()
    private var missionTrace = MKPolyline()
    private var startPin = NamedAnnotation(title: "START")
    private var stopPin = NamedAnnotation(title: "STOP")

    override func viewDidLoad() {
        super.viewDidLoad()

        initFeedbackCaption()
        initButtonStyle()
        initLocationManager()
        initMapView()
        initDroneAnnotation()

        drawMissionTrace()
        observeMissionProgress()
    }

    private func initButtonStyle() {
        uploadMissionButton.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        startMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        createFlightPathButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        centerMapOnDroneButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        pauseMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        setCurrentIndexButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        downloadMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        isMissionFinishedButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
    }

    private func initFeedbackCaption() {
        feedbackLabel.text = "Welcome"
        feedbackLabel.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        feedbackLabel?.layer.masksToBounds = true
        feedbackLabel?.layer.borderColor = UIColor.lightGray.cgColor
        feedbackLabel?.layer.borderWidth = 1.0
    }

    private func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    private func initMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true

        mapView.addAnnotation(startPin)
        mapView.addAnnotation(stopPin)
    }

    private func initDroneAnnotation() {
        mapView.addAnnotation(droneAnnotation)

        _ = drone.telemetry.position
            .observeOn(MainScheduler.instance)
            .map({ position -> CLLocation in
                CLLocation(latitude: position.latitudeDeg, longitude: position.longitudeDeg)
            })
            .do(onNext: { position in self.droneAnnotation.coordinate = position.coordinate },
                onError: { error in print("Error initializing map location: \(error)")})
            .subscribe()
    }

    private func observeMissionProgress() {
        drone.mission.missionProgress
            .observeOn(MainScheduler.instance)
            .do(onNext: { missionProgress in
                    print("Got mission progress update")
                    self.displayFeedback(message:"Mission progress: \(missionProgress.currentItemIndex) / \(missionProgress.missionCount)") },
                onError: { error in print("Error mission progress") })
            .subscribe()
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerOnDroneLocation()
    }

    private func centerOnDroneLocation() {
        _ = drone.telemetry.position
            .observeOn(MainScheduler.instance)
            .take(1)
            .map({ position -> CLLocation in
                CLLocation(latitude: position.latitudeDeg, longitude: position.longitudeDeg)
            })
            .asSingle()
            .do(onSuccess: { position in self.centerMapOnLocation(location: position) },
                onError: { error in print("Error initializing map location: \(error)")})
            .subscribe()
    }

    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func uploadMissionPressed(_ sender: Any) {
        displayFeedback(message:"Upload Mission Pressed")
        uploadMission()
    }

    private func uploadMission() {
        _ = drone.mission.setReturnToLaunchAfterMission(enable: true).subscribe()
        drone.mission.uploadMission(missionItems: mission.missionItems)
            .do(onError: { error in
                self.displayFeedback(message:"Mission uploaded failed \(error)")

            }, onCompleted: {
                self.displayFeedback(message:"Mission uploaded with success")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func cancelUploadMissionButton(_ sender: Any) {
        displayFeedback(message:"Cancel Upload Mission Pressed")
        cancelUploadMission()
    }
    
    private func cancelUploadMission() {
        drone.mission.cancelMissionUpload()
            .do(onError: { error in
                self.displayFeedback(message:"Mission upload cancel failed \(error)")
                
            }, onCompleted: {
                self.displayFeedback(message:"Mission upload cancel with success")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func startMissionPressed(_ sender: Any) {
        displayFeedback(message:"Start Mission Pressed")
        startMission()
    }

    private func startMission() {
        drone.action.arm()
            .catchError({ error -> PrimitiveSequence<CompletableTrait, Never> in
                guard let actionError = error as? Action.ActionError, actionError.code == Action.ActionResult.Result.commandDeniedNotLanded else {
                    throw error
                }
                return Completable.empty()
            })
            .do(onError: { error in self.displayFeedback(message: "Arming failed") })
            .andThen(drone.mission.startMission())
            .do(onError: { error in self.displayFeedback(message: "Mission start failed: \(error)") }, onCompleted: { self.displayFeedback(message:"Mission started") })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func pauseMissionPressed(_ sender: UIButton) {
        displayFeedback(message: "\(String(describing: self.pauseMissionButton.titleLabel?.text)) Pressed")

        if self.pauseMissionButton.titleLabel?.text == "Resume Mission" {
            resumeMission()
        } else {
            pauseMission()
        }
    }

    private func resumeMission() {
        drone.mission.startMission()
            .do(onError: { error in
                self.displayFeedback(message: "Resume mission failed \(error)")
            }, onCompleted: {
                self.displayFeedback(message:"Resume mission with success")
                self.pauseMissionButton.setTitle("Pause Mission", for: .normal)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func pauseMission() {
        drone.mission.pauseMission()
            .do(onError: { error in
                self.displayFeedback(message:"Pausing Mission failed")
            }, onCompleted: {
                self.displayFeedback(message:"Paused mission with success")
                self.pauseMissionButton.setTitle("Resume Mission", for: .normal)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func setIndexPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Set Current Index Pressed")
        setCurrentMissionItem(index: 2)
    }

    private func setCurrentMissionItem(index: Int32) {
        drone.mission.setCurrentMissionItemIndex(index: index)
            .do(onError: { error in self.displayFeedback(message: "Set current mission index failed \(error)") },
                onCompleted: { self.displayFeedback(message:"Set current mission index to \(index).") })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func downloadMissionPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Download Mission Pressed")
        self.downloadMission()
    }

    private func downloadMission() {
        drone.mission.downloadMission()
            .subscribe(onSuccess: { (mission) in
                self.displayFeedback(message:"Downloaded mission")
                print("Mission downloaded: \(mission)")
            }, onError: { (error) in
                self.displayFeedback(message: "Download mission failed \(error)")
            })
            .disposed(by: disposeBag)
    }

    @IBAction func isFinishedPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Is Mission Finished Pressed")
        self.isMissionFinished()
    }

    private func isMissionFinished() {
        drone.mission.isMissionFinished()
            .subscribe(onSuccess: { (finished) in
                self.displayFeedback(message:"Is mission finished: \(finished)")
            }, onError: { (error) in
                self.displayFeedback(message: "Error checking if mission is finihed \(error)")
            })
            .disposed(by: disposeBag)
    }

    @IBAction func centerOnDronePressed(_ sender: Any) {
        centerOnDroneLocation()
    }

    @IBAction func createFlightPathPressed(_ sender: Any) {
        let latitude:String = String(format: "%.4f",
                                     mapView.centerCoordinate.latitude)
        let longitude:String = String(format: "%.4f",
                                      mapView.centerCoordinate.longitude)
        self.displayFeedback(message: "Create flight path at  (\(latitude), \(longitude))")

        let centerMapLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        mission.generateSampleMissionForLocation(location: centerMapLocation)

        drawMissionTrace()
    }

    func drawMissionTrace() {
        mapView.removeOverlay(missionTrace)

        let points = mission.missionItems.map { missionItem -> CLLocationCoordinate2D in
            CLLocationCoordinate2DMake(missionItem.latitudeDeg, missionItem.longitudeDeg)
        }

        missionTrace = MKPolyline(coordinates: points, count: points.count)
        mapView.addOverlay(missionTrace)

        let startMissionItem = mission.missionItems.first!
        startPin.coordinate = CLLocationCoordinate2DMake(startMissionItem.latitudeDeg, startMissionItem.longitudeDeg)

        let stopMissionItem = mission.missionItems.last!
        stopPin.coordinate = CLLocationCoordinate2DMake(stopMissionItem.latitudeDeg, stopMissionItem.longitudeDeg)
    }

    func displayFeedback(message: String) {
        print(message)
        feedbackLabel.text = message
    }
}


extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? NamedAnnotation else { return nil }

        switch (annotation) {
        case startPin, stopPin:
            return CustomPinAnnotationView(annotation: annotation)
        case droneAnnotation:
            return DroneView(annotation: annotation)
        default:
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .orange
            lineRenderer.lineWidth = 2.0
            return lineRenderer
        }

        fatalError("Fatal error in mapView MKOverlayRenderer")
    }
}
