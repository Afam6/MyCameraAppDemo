//
//  SecondViewController.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 18/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import Photos
var albumName = "My Camera App Demo"

class SecondViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    var albumExists = false
    var photoAsset: PHFetchResult<PHAsset>!
    var phAssetCollection: PHAssetCollection!
    
   
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        self.viewDidAppear(true)
    }
    
    @objc func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            print("Landscape")
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("Portrait")
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBAction func photoGallery(_ sender: Any) {
        let imagePicker : UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create a photo album for our app if it does not exist
        
        self.tabBarController?.tabBar.isHidden = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        let notificationCenterTwo = NotificationCenter.default
        notificationCenterTwo.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        let notificationCenterThree = NotificationCenter.default
        notificationCenterThree.addObserver(self, selector: #selector(rotated), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
        let phFetchOptions = PHFetchOptions()
        phFetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: phFetchOptions)
        
        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.albumExists = true
            self.phAssetCollection = first_Obj as! PHAssetCollection
        }else{
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            }, completionHandler: {(success:Bool, error:Error?) in
                if(success){
                    print("Successfully created folder")
                    self.albumExists = true
                    let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                    self.phAssetCollection = collection.firstObject!
                    self.photoAsset = PHAsset.fetchAssets(in: self.phAssetCollection, options: nil)
                    
                }else{
                    print("Error creating folder")
                    self.albumExists = false
                    self.viewDidLoad()
                }
                                                
            })
        }
        
        mapPhotoAsset = self.photoAsset
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Get photos from asset collection
        
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        self.tabBarController?.tabBar.isHidden = false
        
        if albumExists {
            self.photoAsset = PHAsset.fetchAssets(in: self.phAssetCollection, options: nil)
            //mapPhotoAsset = PHAsset.fetchAssets(in: self.phAssetCollection, options: nil)
            print("Photo Asset is !!!!!!!!!.........")
            print(photoAsset)
        } else {
            print("no album found")
        }
        
        self.collectionView.reloadData()
        
        mapPhotoAsset = self.photoAsset
        
        // What if there are no photos in photo collection?
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if(segue.identifier == "viewImage"){
            if let imageViewController:ImageViewController = segue.destination as? ImageViewController{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = self.collectionView.indexPath(for: cell){
                        imageViewController.index = indexPath.item
                        imageViewController.photoAsset = self.photoAsset
                        imageViewController.phAssetCollection = self.phAssetCollection
                    }
                }
            }
        }
    }
    
    //UICollectionViewDataSource required methods
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count = 0
        if self.photoAsset != nil {
            count = self.photoAsset.count
        }
        
        return count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let phAsset: PHAsset = self.photoAsset[indexPath.item]
        
        PHImageManager.default().requestImage(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil, resultHandler: { (result, info) in
            if let image = result {
                cell.setThumbnailImage(thumbnailImage: image)
            }
        })
        
        //cell.backgroundColor = UIColor.red
        
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout methods used
    
   
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var landscape = UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
        
        var width = collectionView.frame.width / 4 - 1
        print(collectionView.frame.width)
        
        if !landscape {
            width = collectionView.frame.width / 4 - 1
            print(collectionView.frame.width)
            print("portrait")
            landscape = false
        } else {
            width = collectionView.frame.width / 7 - 1
            print(collectionView.frame.width)
            print("landscape")
            landscape = true
        }
        
        return CGSize(width: width, height: width);
    }
    
    
    
    // UIImagePickerControllerDelegate methods used
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        NSLog("in didFinishPickingMediaWithInfo")
        
        //Image 
        if let uiImage = info[UIImagePickerControllerPHAsset] as? PHAsset {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    //let createdAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: uiImage) // Add to main photo gallery
                    //let x = PHAssetChangeRequest.init(for: uiImage)
                    // Use placeholder to add image to album for our app
                    
                    //let createdAssetPlaceholder = createdAssetRequest.placeholderForCreatedAsset
                    
                    //let changeRequest = PHAssetChangeRequest.init(for: uiImage);
                    //let createdAssetPlaceholder = changeRequest.placeholderForCreatedAsset
                    
                    let enumeration:NSArray = [uiImage];
                    
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.phAssetCollection, assets: self.photoAsset) {
                        //albumChangeRequest.addAssets([createdAssetPlaceholder!] as NSArray)
                        
                        let cnt = self.phAssetCollection.estimatedAssetCount
                        if cnt == 0{
                            albumChangeRequest.addAssets(enumeration)
                            print(cnt)
                            print("Yooo")
                        }else{
                            albumChangeRequest.insertAssets(enumeration, at: [0])
                            print(cnt)
                            print("Hello afam")
                        }
                    }
                    
                }, completionHandler: {(success, error)in
                    DispatchQueue.main.async(execute: {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        print(info["UIImagePickerControllerOriginalImage"]!)
                        
                        
                        picker.dismiss(animated: true, completion: nil)
                    })
                })
                
            })
        }
 
        
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    

}

