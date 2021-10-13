//

import Foundation
import MapKit


class PinAnnotation: NSObject, MKAnnotation {
    var pin: Pin
    
    dynamic var coordinate: CLLocationCoordinate2D {
        didSet {
            pin.longitude = coordinate.longitude
            pin.latitude = coordinate.latitude
        }
    }
    
    init(pin: Pin) {
        self.pin = pin
        
        let coordinate = CLLocationCoordinate2D(
            latitude: pin.latitude,
            longitude: pin.longitude
        )
        self.coordinate = coordinate
    }
}


