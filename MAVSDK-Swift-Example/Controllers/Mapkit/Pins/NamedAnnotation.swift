import UIKit
import MapKit

class NamedAnnotation: MKPointAnnotation {

    var labelTitle: String 
    
    init(title: String) {
        self.labelTitle = title
    }
}
