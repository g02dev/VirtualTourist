// 

import UIKit
import MapKit
import CoreData

class PinAlbumViewController: UIViewController {
    
    // MARK: - IDOutlets and IBActions
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBAction func handleLoadNewCollection(_ sender: Any) {
        reloadPhotos()
    }
    
    @IBAction func deletePin(_ sender: UIBarButtonItem) {
        dataController.viewContext.delete(pin)
        try? dataController.viewContext.saveIfNeeded()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Variables and Constants

    var pin: Pin!
    
    private let spacing: CGFloat = 1.0
    private let cellsInRow: Int = 3
    
    private var fetchResultsController: NSFetchedResultsController<Photo>!
    
    private lazy var dataController: DataController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.dataController
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backItem?.title = "OK"

        collectionView.dataSource = self
        collectionView.delegate = self
        
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        setCollectionViewCellsSize()
        
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.ReuseIds.pinAnnotationView)
        mapView.delegate = self
        addMapAnnotation()
        setMapCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFetchResultController()
        
        let fetchedPhotos = fetchResultsController.fetchedObjects ?? []
        if fetchedPhotos.count == 0 {
            reloadPhotos()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setCollectionViewCellsSize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    
    
    // MARK: - FetchResultsController
    
    private func setFetchResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin.id)-photos")
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            let alertTitle = Constants.Alert.imagesLoadFailedTitle
            let alertImage = error.localizedDescription
            showAlert(title: alertTitle, message: alertImage)
        }
    }
    
    
    // MARK: - Collection view
    
    private func setCollectionViewCellsSize() {
        let width = collectionView.frame.size.width
        let size = (width - CGFloat(cellsInRow - 1) * spacing) / CGFloat(cellsInRow)
        let itemSize = CGSize(width: size, height: size)

        flowLayout.itemSize = itemSize
    }
    
    
    // MARK: - Photos
        
    private func reloadPhotos() {
        deletePhotos()
        loadPhotosFromFlickr()
    }
    
    private func deletePhotos() {
        let photos = fetchResultsController.fetchedObjects ?? []
        for photo in photos {

            dataController.viewContext.delete(photo)
        }
                
        try? dataController.viewContext.saveIfNeeded()
    }
    
    private func loadPhotosFromFlickr() {
        newCollectionButton.isEnabled = false
        
        FlickrClient().searchPhoto(latitude: pin.latitude, longitude: pin.longitude, numberOfPhotos: Constants.numberOfPhotos) { [weak self] result in
            guard let self = self else { return }
            
            self.newCollectionButton.isEnabled = true
            
            switch result {
            case .success(let newFlickrPhotos):
                for flickrPhoto in newFlickrPhotos {
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.url = flickrPhoto.url
                    photo.pin = self.pin
                }
                try? self.dataController.viewContext.saveIfNeeded()
            case .failure(let error):
                let alertTitle = Constants.Alert.imagesLoadFailedTitle
                let alertMessage = error.description
                self.showAlert(title: alertTitle, message: alertMessage)
            }
        }
    }
    
    
    // MARK: - Map
    
    private func addMapAnnotation() {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(
            latitude: pin.latitude,
            longitude: pin.longitude
        )
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    private func setMapCenter() {
        let coordinate = CLLocationCoordinate2D(
            latitude: pin.latitude,
            longitude: pin.longitude
        )
        mapView.setCenter(coordinate, animated: false)
    }
}


// MARK: - MKMapViewDelegate

extension PinAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.ReuseIds.pinAnnotationView, for: annotation)
        return view
    }
}


// MARK: - UICollectionViewDataSource

extension PinAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ReuseIds.imageCell, for: indexPath) as! ImageCollectionViewCell
        cell.photo = photo
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension PinAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
    }
}


// MARK: - NSFetchedResultsControllerDelegate

extension PinAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
