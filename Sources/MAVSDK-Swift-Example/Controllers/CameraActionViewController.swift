import UIKit
import MAVSDK_Swift
import RxSwift

class CameraActionViewController: UIViewController {
    
	@IBOutlet weak var feedbackLabel: UILabel!
	@IBOutlet weak var videoLabel: UIButton!
    @IBOutlet weak var photoIntervalLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackLabel.text = "Welcome"
        feedbackLabel?.layer.masksToBounds = true
        feedbackLabel?.layer.borderColor = UIColor.lightGray.cgColor
        feedbackLabel?.layer.borderWidth = 1.0
        
        _ = drone.camera.cameraStatus
            .subscribe(onNext: { status in
                NSLog("Camera Status: \(status)")
                
            }, onError: { error in
                NSLog("Error cameraStatusSubscription: \(error.localizedDescription)")
            })
    }
    
    @IBAction func capturePicture(_ sender: UIButton) {
        let myRoutine = drone.camera.takePhoto()
            .do(onError: { error in self.feedbackLabel.text = "Photo Capture Failed : \(error.localizedDescription)" },
                onCompleted: { self.feedbackLabel.text = "Photo Capture Success" })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func videoAction(_ sender: UIButton) {
        if(videoLabel.titleLabel?.text == "Start Video") {
            let myRoutine = drone.camera.startVideo()
                .do(onError: { error in self.feedbackLabel.text = "Start Video Failed : \(error.localizedDescription)" },
                    onCompleted: {
                        self.feedbackLabel.text = "Start Video Success"
                        self.videoLabel.setTitle("Stop Video", for: .normal)
                })
            _ = myRoutine.subscribe()
        }
            
        else {
            let myRoutine = drone.camera.stopVideo()
                .do(onError: { error in self.feedbackLabel.text = "Stop Video Failed : \(error.localizedDescription)" },
                    onCompleted: {
                        self.feedbackLabel.text = "Stop Video Success"
                        self.videoLabel.setTitle("Start Video", for: .normal)
                })
            _ = myRoutine.subscribe()
        }
        
    }
    
    @IBAction func photoIntervalAction(_ sender: UIButton) {
        let option = Camera.Option(optionID: "1", optionDescription: "")
        let setting = Camera.Setting(settingID: "CAM_COLORMODE", settingDescription: "", option: option)
        _ = drone.camera.setSetting(setting: setting)
            .do(onError: { error in
                NSLog("failure: setSetting() \(error)")
            }, onCompleted: {
                NSLog("Completed")
            })
            .subscribe()
    }
    
    @IBAction func setVideoMode(_ sender: UIButton) {
        let myRoutine = drone.camera.setMode(cameraMode: Camera.CameraMode.video)
            .do(onError: { error in self.feedbackLabel.text = "Set Video Mode Failed : \(error.localizedDescription)" },
                onCompleted: {  self.feedbackLabel.text = "Set Video Mode Success" })
        _ = myRoutine.subscribe()
    }
    
    class func showAlert(_ message: String?, viewController: UIViewController?) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true) {() -> Void in }
    }
}
