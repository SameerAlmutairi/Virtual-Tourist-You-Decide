//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 02/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import UIKit
import CoreData
import MapKit

// MARK: UIViewController
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pins: [Pin] = []
    var selectedAnnotation: MKAnnotation?
    var annotations = [MKPointAnnotation]()
    var selectedPin: Pin?
    var isEditingEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    fileprivate func setupFetchedResultController() {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        print(fetchedResultsController)
        if let savedPins = try? dataController.viewContext.fetch(fetchRequest) {
            pins = savedPins
        }
        print(pins.count)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateMapView()
            
        } catch {
            fatalError("the fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func EditPin(_ sender: Any) {
        isEditingEnabled = !isEditingEnabled
        if isEditingEnabled == true {
            changeNavTitle(navTitle: "Tap on a pin to delete", title: "Done", color: UIColor.red)
        }
        else {
            changeNavTitle(navTitle: "Virtual Tourist", title: "Edit", color: UIColor.black)

        }
    }
    
    func changeNavTitle(navTitle: String, title: String, color: UIColor ){
        EditButton.title = title
        navigationItem.title = navTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
    }
    
    @IBAction func longPressHandler(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state != UIGestureRecognizer.State.began {
            return
        }
        let touchPoint = longPressGestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        createAnnotations(to: coordinate)
        let pin = Pin(context: dataController.viewContext)
        pin.coordinate = coordinate
        try? dataController.viewContext.save()
        pins.append(pin)
    }
    
    // create new annotation uisng given coordinates
    func createAnnotations(to coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        annotations.append(annotation)
    }
    
    // add update mapView function
    func updateMapView() {
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        guard let pins = fetchedResultsController.fetchedObjects else { return }
        for pin in pins {
            createAnnotations(to: pin.coordinate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photosViewController = segue.destination as? PhotosViewController, let pin = sender as? Pin {
            photosViewController.selectedPin = pin
        }
    }
}



// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let pin = pins.first(where: { $0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude })
        
        if isEditingEnabled {
            let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "pin == %@", pin!)
            do {
                let objects = try! dataController.viewContext.fetch(fetchRequest)
                for object in objects {
                   dataController.viewContext.delete(object)
                }
                mapView.removeAnnotation(view.annotation!)
                 try! dataController.viewContext.save()
            } catch _ {
               //  error handling
            }
        }
        else {
            let pin = pins.first(where: { $0.latitude == view.annotation?.coordinate.latitude && $0.longitude == view.annotation?.coordinate.longitude })
            self.selectedAnnotation = view.annotation
            self.selectedPin = pin
            performSegue(withIdentifier: "DisplayPhotos", sender: selectedPin)
        }

        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // Update MapView
        updateMapView()
    }
}
