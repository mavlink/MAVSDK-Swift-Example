import UIKit
import Mavsdk
import MavsdkServer

var drone: Drone? = Optional.none
let cloudSimIP: String = "3.236.108.82"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mavsdkServer = MavsdkServer()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let port = mavsdkServer.run(systemAddress: "tcp://\(cloudSimIP):5790")
//        let port = mavsdkServer.run()
        drone = Drone(port: Int32(port))

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {
        self.mavsdkServer.stop()
    }
}
