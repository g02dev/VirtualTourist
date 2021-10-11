//

import Foundation
import MapKit


class PinAnnotation: MKPointAnnotation {
    
    var pin: Pin
    
    init(pin: Pin) {
        self.pin = pin
        super.init()
        
        let coordinate = CLLocationCoordinate2D(
            latitude: pin.latitude,
            longitude: pin.longitude
        )
        self.coordinate = coordinate
    }
}


