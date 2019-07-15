//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 02/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var dataController: DataController! {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.dataController
    }
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var selectedPin: Pin!
    var photosDeleted: Bool = false
    var page: Int = 1
    var arePhotosDownloadedAlready: Bool {
        if fetchedResultsController.fetchedObjects?.count != 0 {
            return true
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultController()
        collectionView.reloadData()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchedResultsController = NSFetchedResultsController<Photo>(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if arePhotosDownloadedAlready {
                updateView(false)
            }
            else {
                downloadImages()
            }
        } catch {
            fatalError("the fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func updateView(_ updating: Bool) {
        if updating {
            newCollectionButton.title = ""
            activityIndicatorView.startAnimating()
        }
        else {
            newCollectionButton.title = "New Collection"
             activityIndicatorView.stopAnimating()
        }
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        downloadImages()
    }
    
    func downloadImages(){
        updateView(true)
        // checking if there are photos in CoreData then delete them
        if arePhotosDownloadedAlready {
            photosDeleted = true
            for photo in fetchedResultsController.fetchedObjects! {
                dataController.viewContext.delete(photo)
            }
            try? dataController.viewContext.save()
            // change the variable after deleting all photos
            photosDeleted = false
        }
        FlickrClient.getPhotoForCoordinate(lon: selectedPin.longitude, lat: selectedPin.latitude, page: page) { (response, error) in
            DispatchQueue.main.async {
                self.page = self.page + 1
                self.updateView(false)
                if error != nil  {
                    print(error)
                    return
                }
                guard let response = response  else {
//                    self.labelMessage.isHidden = false
                    return
                }
                if response.count == 0 {
                    self.labelMessage.isHidden = false
                }
                print("response.count \(response.count)")
                for responseURL in response {
                    print(responseURL.photoURL)
                    print()
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.imageURL = responseURL.photoURL
                    photo.pin = self.selectedPin
                }
                try? self.dataController.viewContext.save()
            }
        }
    }
    
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.cellActivityindicator.startAnimating()
        if let data = NSData(contentsOf: URL(string: photo.imageURL!)!){
            cell.imageView.image = UIImage(data: data as Data)
        }
        cell.cellActivityindicator.stopAnimating()
        
        return cell
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
