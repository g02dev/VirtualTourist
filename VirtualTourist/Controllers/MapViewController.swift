// 

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {
    
    // MARK: - IBOutlets and IBActions
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Variables and Constants
    private var newPinAnnotation: PinAnnotation?
    
    private var pins: [Pin] = []
    
    private lazy var dataController: DataController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dataController
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPins()
        
        mapView.delegate = self
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.ReuseIds.pinAnnotationView)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(sender:)))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
        addMapAnnotations()
        setMapRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    // MARK: - Pins
    
    private func loadPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
        } else {
            pins = []
        }
    }
    
    
    // MARK: - Map
    
    private func addMapAnnotations() {
        var annotations: [PinAnnotation] = []
        
        for pin in pins {
            let annotation = PinAnnotation(pin: pin)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    private func setMapRegion() {
        guard pins.count > 0 else { return }
        
        let pin = pins[0]
        let coordinate = CLLocationCoordinate2D(
            latitude: pin.latitude,
            longitude: pin.longitude
        )

         let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1_000_000,
            longitudinalMeters: 1_000_000
         )
         mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: - Gesture
    
    @objc func handleLongPressGesture(sender: UIGestureRecognizer) {
        let locationInView = sender.location(in: mapView)
        let locationInMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        switch sender.state {
        case .began:
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = locationInMap.latitude
            pin.longitude = locationInMap.longitude
            
            let annotation = PinAnnotation(pin: pin)
            mapView.addAnnotation(annotation)
            newPinAnnotation = annotation
        case .changed:
            newPinAnnotation?.coordinate = locationInMap
        case .ended:
            if let newPinAnnotation = newPinAnnotation {
                newPinAnnotation.coordinate = locationInMap
                mapView.selectAnnotation(newPinAnnotation, animated: false)
            }
            try? dataController.viewContext.save()
        case .failed, .cancelled:
            if let newPinAnnotation = newPinAnnotation {
                mapView.removeAnnotation(newPinAnnotation)
                
                let pin = newPinAnnotation.pin
                dataController.viewContext.delete(pin)
            }
            newPinAnnotation = nil
        default:
            break
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.showPinAlbumVC,
           let vc = segue.destination as? PinAlbumViewController,
           let pin = sender as? Pin {
            vc.pin = pin
        }
    }
}


// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.ReuseIds.pinAnnotationView, for: annotation)
        return view
    }
        
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        mapView.deselectAnnotation(annotation, animated: false)
    
        if let annotation = annotation as? PinAnnotation {
            let pin = annotation.pin
            performSegue(withIdentifier: Constants.Segue.showPinAlbumVC, sender: pin)
        }
    }
}
