//
//  PreviewViewController.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 27/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class PreviewViewController: UIViewController, CLLocationManagerDelegate {
    
    var image: UIImage!
    var locationManager = CLLocationManager()

    @IBOutlet var photoImageView: UIImageView!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        CustomPhotoAlbum.sharedInstance.saveImage(image: image, location: locationManager.location!)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImageView.image = self.image
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}

class CustomPhotoAlbum {
    
    static let albumName = "My Camera App Demo"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    var asset: PHFetchResult<PHAsset>!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if collection.firstObject != nil {
                print("found the album!")
                return collection.firstObject
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            self.asset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
                self.asset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
            }
        }
    }
    
    func saveImage(image: UIImage, location: CLLocation) {
        
        if assetCollection == nil {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            assetChangeRequest.location = location
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let enumeration:NSArray = [assetPlaceholder!]
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.asset) {
                let cnt = self.assetCollection.estimatedAssetCount
                if cnt == 0{
                    albumChangeRequest.addAssets(enumeration)
                    print(cnt)
                    print("Yooo")
                }else{
                    albumChangeRequest.insertAssets(enumeration, at: [self.asset.count])
                    print(cnt)
                    print("Hello afam")
                }
            }
        }, completionHandler: nil)
    }
    
    
}
