import Dronecode_SDK_Swift
import MapKit
import RxSwift
import UIKit

private enum EntryType : Int {
    case connection = 0
    case health
    case altitude
    case latitude_longitude
    case armed
    case groundspeed
    case battery
    case attitude
    case gps
    case in_air
    case entry_type_max
}

private class TelemetryEntry {

    var property: String
    var value: String

    init(property: String, value: String = "-") {
        self.property = property
        self.value = value
    }
}

class TelemetryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var telemetryTableView: UITableView!
    
    private var entries = [TelemetryEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionLabel.text = "Starting system ..."
        
        self.telemetryTableView.delegate = self
        self.telemetryTableView.dataSource = self

        entries = generateEntries()

        _ = CoreManager.shared.startCompletable.subscribe(onCompleted: { self.startObserving() })
    }

    private func generateEntries() -> [TelemetryEntry] {
        var entries = [TelemetryEntry]()

        entries.append(TelemetryEntry(property: "Connection", value: "No Connection"))
        entries.append(TelemetryEntry(property: "Health"))
        entries.append(TelemetryEntry(property: "Relative, absolute altitude"))
        entries.append(TelemetryEntry(property: "Latitude, longitude"))

        return entries
    }

    private func startObserving() {
        observeConnection()
        observeHealth()
        observePosition()
    }

    private func observeConnection() {
        _ = CoreManager.shared.core.discoverObservable.subscribe(onNext: { uuid in self.onConnected(uuid: uuid)})
    }

    private func onConnected(uuid: UInt64) {
        print("Drone Connected with UUID : \(uuid)")

        connectionLabel.text = "Connected"
        entries[EntryType.connection.rawValue].value = "Drone Connected with UUID : \(uuid)"

        telemetryTableView.reloadData()
    }

    private func observeHealth() {
        _ = CoreManager.shared.telemetry.healthObservable
                .subscribe(onNext: { health in self.onHealthUpdate(health: health) },
                           onError: { error in print(error) })
    }

    private func onHealthUpdate(health: Health)
    {
        entries[EntryType.health.rawValue].value = "Calibration \(health.isAccelerometerCalibrationOk ? "Ready" : "Not OK"), GPS \(health.isLocalPositionOk ? "Ready" : "Acquiring")"

        telemetryTableView.reloadData()
    }

    private func observePosition() {
        _ = CoreManager.shared.position
                .subscribe(onNext: { position in self.onPositionUpdate(position: position)},
                           onError: { error in print(error) })
    }

    private func onPositionUpdate(position: Position) {
        entries[EntryType.altitude.rawValue].value = "\(position.relativeAltitudeM) m, \(position.absoluteAltitudeM) m"

        entries[EntryType.latitude_longitude.rawValue].value = "\(position.latitudeDeg) Deg, \(position.longitudeDeg) Deg"

        telemetryTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TelemetryCell", for: indexPath)
        
        if (entries.count > indexPath.row) {
            let entry = entries[indexPath.row]
            
            cell.textLabel?.text = entry.value;
            cell.detailTextLabel?.text = entry.property;
        }
        
        return cell
    }
}
