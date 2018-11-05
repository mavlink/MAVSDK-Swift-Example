import Foundation
import MapKit

class DroneState: NSObject{
    
    var location2D: CLLocationCoordinate2D
    
    override init(){
        self.location2D = CLLocationCoordinate2DMake(0, 0);
    }
}
