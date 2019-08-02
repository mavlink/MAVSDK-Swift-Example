import MAVSDK_Swift
import MapKit
import RxSwift
import UIKit

private enum EntryType : Int {
    case connection = 0
    case health
    case altitude
    case latitude_longitude
    case flight_mode
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

class TelemetryViewController: UIViewController {

    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var telemetryTableView: UITableView!
    
    private var entries = [TelemetryEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()

        connectionLabel.text = "Starting system ..."
        
        self.telemetryTableView.delegate = self
        self.telemetryTableView.dataSource = self

        entries = generateEntries()

        _ = drone.startMavlink
            .subscribe(onCompleted: { self.startObserving() })
    }

    private func generateEntries() -> [TelemetryEntry] {
        var entries = [TelemetryEntry]()

        entries.append(TelemetryEntry(property: "Connection", value: "No Connection"))
        entries.append(TelemetryEntry(property: "Health"))
        entries.append(TelemetryEntry(property: "Relative, absolute altitude"))
        entries.append(TelemetryEntry(property: "Latitude, longitude"))
        entries.append(TelemetryEntry(property: "Flight Mode"))
        entries.append(TelemetryEntry(property: "Armed"))
        entries.append(TelemetryEntry(property: "Ground Speed"))
        entries.append(TelemetryEntry(property: "Battery"))
        entries.append(TelemetryEntry(property: "Attitude"))
        entries.append(TelemetryEntry(property: "GPS"))
        entries.append(TelemetryEntry(property: "In Air"))

        return entries
    }

    private func startObserving() {
        observeConnection()
        observeHealth()
        observePosition()
        observeFlightMode()
        observeArmed()
        observeGroundSpeed()
        observeBattery()
        observeAttitude()
        observeGPS()
        observeInAir()
    }
}

// MARK: - DroneCode Observations
extension TelemetryViewController {
    private func observeConnection() {
        _ = drone.core.connectionState
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { connectionState in
                    if (connectionState.isConnected) {
                        self.onConnected(uuid: connectionState.uuid)
                    } else {
                        self.onDisconnected()
                    }
                })
    }

    private func onConnected(uuid: UInt64) {
        print("Drone connected with UUID : \(uuid)")

        connectionLabel.text = "Connected"
        entries[EntryType.connection.rawValue].value = "Drone UUID : \(uuid)"

        telemetryTableView.reloadData()
    }

    private func onDisconnected() {
        print("Drone disconnected")

        connectionLabel.text = "Disconnected"
        entries[EntryType.connection.rawValue].value = "Drone disconnected"

        telemetryTableView.reloadData()
    }

    private func observeHealth() {
        _ = drone.telemetry.health
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { health in self.onHealthUpdate(health: health) },
                           onError: { error in print(error) })
    }

    private func onHealthUpdate(health: Telemetry.Health)
    {
        entries[EntryType.health.rawValue].value = "Calibration \(health.isAccelerometerCalibrationOk ? "Ready" : "Not OK"), GPS \(health.isLocalPositionOk ? "Ready" : "Acquiring")"

        telemetryTableView.reloadData()
    }

    private func observePosition() {
        _ = drone.telemetry.position
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { position in self.onPositionUpdate(position: position)},
                           onError: { error in print(error) })
    }

    private func onPositionUpdate(position: Telemetry.Position) {
        let relativeAltString = String(format: "%.2f", position.relativeAltitudeM)
        let absoluteAltString = String(format: "%.2f", position.absoluteAltitudeM)
        
        entries[EntryType.altitude.rawValue].value = "\(relativeAltString) m, \(absoluteAltString) m"

        let latitudeString = String(format: "%.7f", position.latitudeDeg)
        let longitudeString = String(format: "%.7f", position.longitudeDeg)

        entries[EntryType.latitude_longitude.rawValue].value = "\(latitudeString)° | \(longitudeString)°"

        telemetryTableView.reloadData()
    }
    
    private func observeFlightMode() {
        _ = drone.telemetry.flightMode
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { mode in self.onFlightModeUpdate(mode: mode)},
                       onError: { error in print(error) })
    }
    
    private func onFlightModeUpdate(mode: Telemetry.FlightMode) {
        var modeString = ""
        switch mode {
        case .unknown:
            modeString = "Unknown"
        case .ready:
            modeString = "Ready"
        case .takeoff:
            modeString = "Take Off"
        case .hold:
            modeString = "Hold"
        case .mission:
            modeString = "Mission"
        case .returnToLaunch:
            modeString = "RTL"
        case .land:
            modeString = "Land"
        case .offboard:
            modeString = "Offboard"
        case .followMe:
            modeString = "Follow Me"
        case .UNRECOGNIZED(_):
            modeString = "Unrecognized"
        }
        
        self.entries[EntryType.flight_mode.rawValue].value = modeString
        self.telemetryTableView.reloadData()
    }
    
    private func observeArmed() {
        _ = drone.telemetry.armed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { armed in self.onArmedUpdate(armed: armed) },
                       onError: { error in print(error) })
    }
    
    private func onArmedUpdate(armed: Bool) {
        let isArmed = armed ? "Yes" : "No"
        
        self.entries[EntryType.armed.rawValue].value = "\(isArmed)"
        self.telemetryTableView.reloadData()
    }
    
    private func observeGroundSpeed() {
        _ = drone.telemetry.groundSpeedNed
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { groundSpeed in self.onGroundSpeedUpdate(groundSpeed: groundSpeed) },
                       onError: { error in print(error) })
    }
    
    private func onGroundSpeedUpdate(groundSpeed: Telemetry.SpeedNed) {
        let northFormattedString = String(format: "%.3f", groundSpeed.velocityNorthMS)
        let eastFormattedString = String(format: "%.3f", groundSpeed.velocityEastMS)
        let downFormattedString = String(format: "%.3f", groundSpeed.velocityDownMS)

        self.entries[EntryType.groundspeed.rawValue].value = "N: \(northFormattedString) m/s | E: \(eastFormattedString) m/s | D: \(downFormattedString) m/s"
        self.telemetryTableView.reloadData()
    }
    
    private func observeBattery() {
        _ = drone.telemetry.battery
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { battery in self.onBatteryUpdate(battery: battery) },
                       onError: { error in print(error) })
    }
    
    private func onBatteryUpdate(battery: Telemetry.Battery) {
        let voltageString = String(format: "%.2f", battery.voltageV)

        self.entries[EntryType.battery.rawValue].value = "\(battery.remainingPercent * 100.0) % | \(voltageString) V"
        self.telemetryTableView.reloadData()
    }
    
    private func observeAttitude() {
        _ = drone.telemetry.attitudeEuler
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { attitude in self.onAttitudeUpdate(attitude: attitude) },
                       onError: { error in print(error) })
    }
    
    private func onAttitudeUpdate(attitude: Telemetry.EulerAngle) {
        let rollString = String(format: "%.2f", attitude.rollDeg)
        let pitchString = String(format: "%.2f", attitude.pitchDeg)
        let yawString = String(format: "%.2f", attitude.yawDeg)

        self.entries[EntryType.attitude.rawValue].value = "Roll: \(rollString) | Pitch: \(pitchString) | Yaw: \(yawString)"
        self.telemetryTableView.reloadData()
    }
    
    private func observeGPS() {
        _ = drone.telemetry.gpsInfo
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{ gps in self.onGPSUpdate(gps: gps) },
                       onError: { error in print(error) })
    }
    
    private func onGPSUpdate(gps: Telemetry.GpsInfo) {
        var fixTypeString = ""
        
        switch gps.fixType {
        case .noGps:
            fixTypeString = "GPS"
        case .noFix:
            fixTypeString = "Fix"
        case .fix2D:
            fixTypeString = "2D"
        case .fix3D:
            fixTypeString = "3d"
        case .fixDgps:
            fixTypeString = "Dgps"
        case .rtkFloat:
            fixTypeString = "RTK Float"
        case .rtkFixed:
            fixTypeString = "RTK Fixed"
        case .UNRECOGNIZED(_):
            fixTypeString = "Unrecognized"
        }
        
        self.entries[EntryType.gps.rawValue].value = "Satellites: \(gps.numSatellites) | Fix: \(fixTypeString)"
        self.telemetryTableView.reloadData()
    }
    
    private func observeInAir() {
        _ = drone.telemetry.inAir
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{ inAir in self.onInAirUpdate(inAir: inAir) },
                       onError: { error in print(error) })
    }
    
    private func onInAirUpdate(inAir: Bool) {
        let isInAir = inAir ? "Yes" : "No"
        
        self.entries[EntryType.in_air.rawValue].value = "\(isInAir)"
        self.telemetryTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TelemetryViewController: UITableViewDataSource, UITableViewDelegate  {
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
