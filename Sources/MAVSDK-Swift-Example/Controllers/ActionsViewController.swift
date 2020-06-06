import UIKit
import MAVSDK_Swift

let UI_CORNER_RADIUS_BUTTONS = CGFloat(8.0)

class ActionsViewController: UIViewController {

    @IBOutlet weak var armButton: UIButton!
    @IBOutlet weak var takeoffButton: UIButton!
    @IBOutlet weak var landButton: UIButton!
    @IBOutlet weak var disarmButton: UIButton!
    @IBOutlet weak var returnToLaunchButton: UIButton!
    @IBOutlet weak var transitionToFixedWingButton: UIButton!
    @IBOutlet weak var transitionToMulticopterButton: UIButton!
    @IBOutlet weak var getTakeoffAltitudeButton: UIButton!
    @IBOutlet weak var getMaxSpeedButton: UIButton!
    
    @IBOutlet weak var feedbackLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Init feeback text and add round corners/borders
        feedbackLabel.text = "Welcome"
        feedbackLabel.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        feedbackLabel?.layer.masksToBounds = true
        feedbackLabel?.layer.borderColor = UIColor.lightGray.cgColor
        feedbackLabel?.layer.borderWidth = 1.0
        
        // Set button corners
        armButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        takeoffButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        landButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        disarmButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        returnToLaunchButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        transitionToFixedWingButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        transitionToMulticopterButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        getTakeoffAltitudeButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        getMaxSpeedButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
    }
    
    @IBAction func armPressed(_ sender: Any) {
        _ = drone!.action.arm()
            .do(onError: { error in  self.feedbackLabel.text = "Arming Failed : \(error.localizedDescription)" },
                onCompleted: {  self.feedbackLabel.text = "Arming Succeeded"})
            .subscribe()
    }
    
    @IBAction func disarmPressed(_ sender: Any) {
        _ = drone!.action.disarm()
            .do(onError: { error in self.feedbackLabel.text = "Disarming Failed: \(error.localizedDescription)"  }, onCompleted: { self.feedbackLabel.text = "Disarming succeeded" })
            .subscribe()
    }
    
    @IBAction func takeoffPressed(_ sender: Any) {
         _ = drone!.action.takeoff()
            .do(onError: { error in self.feedbackLabel.text = "Takeoff Failed" }, onCompleted: { self.feedbackLabel.text = "Takeoff Succeeded" })
            .subscribe()
    }
    
    @IBAction func landPressed(_ sender: Any) {
         _ = drone!.action.land()
            .do(onError: { error in self.feedbackLabel.text = "Land Failed" }, onCompleted: { self.feedbackLabel.text = "Land Succeeded" })
            .subscribe()
    }
    
    @IBAction func returnToLaunchPressed(_ sender: Any) {
        _ = drone!.action.returnToLaunch()
            .do(onError: { error in self.feedbackLabel.text = "Return To Launch Failed" }, onCompleted: { self.feedbackLabel.text = "Return To Launch Succeeded"})
            .subscribe()
    }
    
    @IBAction func transitionToFixedWingPressed(_ sender: Any) {
        _ = drone!.action.transitionToFixedwing()
            .do(onError: { error in self.feedbackLabel.text = "Transition To Fixed Wing Failed"},
                onCompleted: { self.feedbackLabel.text = "Transition To Fixed Wing Succeeded"})
            .subscribe()
    }
    
    @IBAction func transitionToMulticopterPressed(_ sender: Any) {
        _ = drone!.action.transitionToMulticopter()
            .do(onError: { error in self.feedbackLabel.text = "Transition To Multicopter Failed"},
                onCompleted: { self.feedbackLabel.text = "Transition To Multicopter Succeeded"})
            .subscribe()
    }
    
    @IBAction func getTakeoffAltitudePressed(_ sender: Any) {
        _ = drone!.action.getTakeoffAltitude()
            .do(onSuccess: { altitude in self.feedbackLabel.text = "Takeoff Altitude: \(altitude)" },
                onError: { error in self.feedbackLabel.text = "Get Takeoff Altitude Failure: \(error)" })
            .subscribe()
    }

    @IBAction func getMaximumSpeedPressed(_ sender: Any) {
        _ = drone!.action.getMaximumSpeed()
            .do(onSuccess: { speed in self.feedbackLabel.text = "Maximum speed: \(speed)" },
                onError: { error in self.feedbackLabel.text = "Get Maximum Speed Failure: \(error)" })
            .subscribe()
    }

    class func showAlert(_ message: String?, viewController: UIViewController?) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true) {() -> Void in }
    }
}
