//
//  ImageViewController.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 18/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import Photos

class ImageViewController: UIViewController {
    
    var photoAsset: PHFetchResult<PHAsset>!
    var phAssetCollection: PHAssetCollection!
    var index = 0

    @IBOutlet var imageView: UIImageView!
    @IBAction func deleteButton(_ sender: Any) {
        print("Delete")
        
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
            PHPhotoLibrary.shared().performChanges({
                //Delete Photo
                if let request = PHAssetCollectionChangeRequest(for: self.phAssetCollection){
                    request.removeAssets(at: IndexSet([self.index]))
                }
            }, completionHandler: {(success, error)in
                NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                alert.dismiss(animated: true, completion: nil)
                if(success){
                    // Move to the main thread to execute
                    DispatchQueue.main.async(execute: {
                        self.photoAsset = PHAsset.fetchAssets(in: self.phAssetCollection, options: nil)
                        if(self.photoAsset.count == 0){
                            print("No Images Left!!")
                            if let navController = self.navigationController {
                                navController.popToRootViewController(animated: true)
                            }
                        }else{
                            if(self.index >= self.photoAsset.count){
                                self.index = self.photoAsset.count - 1
                            }
                            self.enlargeImage()
                        }
                    })
                }else{
                    print("Error: \(String(describing: error))")
                }
                
                mapPhotoAsset = self.photoAsset
                                                   
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func shareButton(_ sender: Any) {
        print("Share")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        
        self.enlargeImage()
        
        if (self.navigationController?.isToolbarHidden)! {
            print("Hidden")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //
        
        if (self.navigationController?.isToolbarHidden)!{
            print("Touch began")
            imageView.backgroundColor = UIColor.white
            self.tabBarController?.tabBar.isHidden = false
        } else {
            imageView.backgroundColor = UIColor.black
            self.tabBarController?.tabBar.isHidden = true
            //print(self.tabBarController?.tabBar.isHidden)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func enlargeImage(){
        _ = PHImageManager.default().requestImage(for: self.photoAsset[self.index], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {(result, info) in
                self.imageView.image = result
                //print(self.photoAsset[self.index].location.coordinate.longitude)
                print(self.photoAsset[self.index].location?.coordinate.longitude)
        })
    }
    

}
