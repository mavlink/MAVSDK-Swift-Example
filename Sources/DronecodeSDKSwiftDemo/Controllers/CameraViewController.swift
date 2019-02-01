import UIKit

class CameraViewController: UIViewController, VLCMediaPlayerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    var mediaPlayer = VLCMediaPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraView.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Play example rtsp stream
        let url = URL(string: "rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov")
        
        let media = VLCMedia(url: url!)
        mediaPlayer.media = media
        mediaPlayer.delegate = self
        mediaPlayer.drawable = self.cameraView
        
        //TODO modify this
        mediaPlayer.play()
    }
}
