import UIKit
import Dronecode_SDK_Swift
import MapKit
import RxSwift

class MapViewController: UIViewController, CLLocationManagerDelegate {

    var disposeBag = DisposeBag()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var uploadMissionButton: UIButton!
    @IBOutlet weak var startMissionButton: UIButton!
    @IBOutlet weak var pauseMissionButton: UIButton!
    @IBOutlet weak var getCurrentIndexButton: UIButton!
    @IBOutlet weak var setCurrentIndexButton: UIButton!
    @IBOutlet weak var downloadMissionButton: UIButton!
    @IBOutlet weak var getMissionCountButton: UIButton!
    @IBOutlet weak var isMissionFinishedButton: UIButton!

    @IBOutlet weak var createFlightPathButton: UIButton!
    @IBOutlet weak var centerMapOnUsernButton: UIButton!

    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    let regionRadius: CLLocationDistance = 100

    private var droneAnnotation: DroneAnnotation!
    private var timer: Timer?

    private let mission = ExampleMission()
    private var missionTrace = MKPolyline()
    private var startPin = CustomPointAnnotation(title: "START")
    private var stopPin = CustomPointAnnotation(title: "STOP")

    override func viewDidLoad() {
        super.viewDidLoad()

        // set initial location of drone and center map on it
        let initialLocation = CLLocation(latitude: CoreManager.shared.droneState.location2D.latitude , longitude: CoreManager.shared.droneState.location2D.longitude)
        centerMapOnLocation(location: initialLocation)

        initFeedbackCaption()
        initButtonStyle()
        initLocationManager()
        initMapView()
        initDroneAnnotation(location: initialLocation)

        // timer to get drone state
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:  #selector(updateDroneInfosDisplayed), userInfo: nil, repeats: true)

        drawMissionTrace()
        observeMissionProgress()
    }

    private func initButtonStyle() {
        uploadMissionButton.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        startMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        createFlightPathButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        centerMapOnUsernButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        pauseMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        getCurrentIndexButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        setCurrentIndexButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        downloadMissionButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
        getMissionCountButton.layer.cornerRadius    = UI_CORNER_RADIUS_BUTTONS
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

    private func initDroneAnnotation(location: CLLocation) {
        mapView.register(DroneView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(DroneView.self))
        droneAnnotation = DroneAnnotation(title: "Drone", coordinate: location.coordinate)
        mapView.addAnnotation(droneAnnotation)
    }

    private func observeMissionProgress() {
        CoreManager.shared.mission.missionProgressObservable
            .do(onNext: { missionProgress in
                    print("Got mission progress update")
                    self.displayFeedback(message:"Mission progress: \(missionProgress.currentItemIndex) / \(missionProgress.missionCount)") },
                onError: { error in print("Error mission progress") })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func uploadMissionPressed(_ sender: Any) {
        displayFeedback(message:"Upload Mission Pressed")
        uploadMission()
    }

    private func uploadMission() {
        CoreManager.shared.mission.uploadMission(missionItems: mission.missionItems)
            .do(onError: { error in
                self.displayFeedback(message:"Mission uploaded failed \(error)")

            }, onCompleted: {
                self.displayFeedback(message:"Mission uploaded with success")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func startMissionPressed(_ sender: Any) {
        displayFeedback(message:"Start Mission Pressed")
        startMission()
    }

    private func startMission() {
        // /!\ NEED TO ARM BEFORE START THE MISSION
        CoreManager.shared.action.arm()
            .do(onError: { error in self.displayFeedback(message:"Arming failed") })
            .andThen(CoreManager.shared.mission.startMission())
            .do(onError: { error in self.displayFeedback(message: "Mission started failed \(error)") }, onCompleted: { self.displayFeedback(message:"Mission started with success") })
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
        CoreManager.shared.mission.startMission()
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
        CoreManager.shared.mission.pauseMission()
            .do(onError: { error in
                self.displayFeedback(message:"Pausing Mission failed")
            }, onCompleted: {
                self.displayFeedback(message:"Paused mission with success")
                self.pauseMissionButton.setTitle("Resume Mission", for: .normal)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func getIndexPressed(_ sender: UIButton) {
        displayFeedback(message:"Get Current Index Pressed")
        getCurrentMissionItem()
    }

    private func getCurrentMissionItem() {
        CoreManager.shared.mission.getCurrentMissionItemIndex()
            .do(onSuccess: { index in self.displayFeedback(message:"Current mission index: \(index)") },
                onError: { error in self.displayFeedback(message: "Get mission index failed \(error)") })
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func setIndexPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Set Current Index Pressed")
        setCurrentMissionItem(index: 2)
    }

    private func setCurrentMissionItem(index: Int) {
        CoreManager.shared.mission.setCurrentMissionItemIndex(index)
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
        CoreManager.shared.mission.downloadMission()
            .subscribe(onSuccess: { (mission) in
                self.displayFeedback(message:"Downloaded mission")
                print("Mission downloaded: \(mission)")
            }, onError: { (error) in
                self.displayFeedback(message: "Download mission failed \(error)")
            })
            .disposed(by: disposeBag)
    }

    @IBAction func getCountPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Get Mission Count Pressed")
        self.getMissionCount()
    }

    private func getMissionCount() {
        CoreManager.shared.mission.getMissionCount()
            .subscribe(onSuccess: { (count) in
                self.displayFeedback(message:"Mission count: \(count)")
            }, onError: { (error) in
                self.displayFeedback(message: "Get mission count failed \(error)")
            })
            .disposed(by: disposeBag)
    }

    @IBAction func isFinishedPressed(_ sender: UIButton) {
        self.displayFeedback(message:"Is Mission Finished Pressed")
        self.isMissionFinished()
    }

    private func isMissionFinished() {
        CoreManager.shared.mission.isMissionFinished()
            .subscribe(onSuccess: { (finished) in
                self.displayFeedback(message:"Is mission finished: \(finished)")
            }, onError: { (error) in
                self.displayFeedback(message: "Error checking if mission is finihed \(error)")
            })
            .disposed(by: disposeBag)
    }

    @IBAction func centerOnUserPressed(_ sender: Any) {
        if let currentLocationLat = currentLocation?.coordinate.latitude, let currentLocationLong = currentLocation?.coordinate.longitude {
            let latitude:String = String(format: "%.4f", currentLocationLat)
            let longitude:String = String(format: "%.4f", currentLocationLong)

            self.displayFeedback(message: "User coordinates: (\(latitude),\(longitude))")

            centerMapOnLocation(location: currentLocation!)
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func createFlightPathPressed(_ sender: Any) {
        let latitude:String = String(format: "%.4f",
                                     mapView.centerCoordinate.latitude)
        let longitude:String = String(format: "%.4f",
                                      mapView.centerCoordinate.longitude)
        self.displayFeedback(message:"Create flight path at  (\(latitude), \(longitude))")

        let centerMapLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        mission.generateSampleMissionForLocation(location: centerMapLocation)

        drawMissionTrace()
    }

    func drawMissionTrace() {
        mapView.remove(missionTrace)

        let points = mission.missionItems.map { missionItem -> CLLocationCoordinate2D in
            CLLocationCoordinate2DMake(missionItem.latitudeDeg, missionItem.longitudeDeg)
        }

        missionTrace = MKPolyline(coordinates: points, count: points.count)
        mapView.add(missionTrace)

        let startMissionItem = mission.missionItems.first!
        startPin.coordinate = CLLocationCoordinate2DMake(startMissionItem.latitudeDeg, startMissionItem.longitudeDeg)

        let stopMissionItem = mission.missionItems.last!
        stopPin.coordinate = CLLocationCoordinate2DMake(stopMissionItem.latitudeDeg, stopMissionItem.longitudeDeg)
    }

    @objc func updateDroneInfosDisplayed(_ _timer: Timer?) {
        DispatchQueue.main.async {
            // Update the UI
            self.droneAnnotation.coordinate = CoreManager.shared.droneState.location2D
        }
    }

    func displayFeedback(message: String) {
        print(message)
        feedbackLabel.text = message
    }
}


extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if (annotation is CustomPointAnnotation) {
            _ = NSStringFromClass(CustomPinAnnotationView.self)
            let  view :CustomPinAnnotationView = CustomPinAnnotationView(annotation: annotation)
            return view
        } else {
            guard let annotation = annotation as? DroneAnnotation else { return nil }

            let identifier = NSStringFromClass(DroneView.self)
            var view: DroneView

            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? DroneView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = DroneView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
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
