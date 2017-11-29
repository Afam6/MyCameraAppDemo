//
//  ImageViewController.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 18/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import Photos

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var photoAsset: PHFetchResult<PHAsset>!
    var phAssetCollection: PHAssetCollection!
    var index = 0
    var contentWidth: CGFloat = 0.0
    var tap = UIShortTapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()

    
    @IBOutlet var scrollView: UIScrollView!
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
        let sharedImage: [Any] = [imageView.image!]
        let sharingViewController = UIActivityViewController(activityItems: sharedImage, applicationActivities: nil)
        self.present(sharingViewController, animated: true, completion: nil)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    @objc func appMovedToForeground() {
        self.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        let notificationCenterTwo = NotificationCenter.default
        notificationCenterTwo.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // Do any additional setup after loading the view.
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.scrollView.contentInsetAdjustmentBehavior = .never

        
        tap.numberOfTapsRequired = 1
        tap.require(toFail: doubleTap)
        tap.addTarget(self, action: #selector(tapScreen))
        self.view.addGestureRecognizer(tap)
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.addTarget(self, action: #selector(doubleTapScreen(recognizer:)))
        self.view.addGestureRecognizer(doubleTap)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.all)
        
        
        self.enlargeImage()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.delaysTouchesBegan = true
        swipeRight.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.delaysTouchesBegan = true
        swipeLeft.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown.delaysTouchesBegan = true
        swipeDown.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        swipeUp.delaysTouchesBegan = true
        swipeUp.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeUp)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.respondtoLongPress))
        longPress.minimumPressDuration = 2
        longPress.delaysTouchesBegan = true
        longPress.cancelsTouchesInView = true
        self.view.addGestureRecognizer(longPress)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        AppUtility.lockOrientation(.portrait)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print("start zoom")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(scrollView.zoomScale)
        if scrollView.zoomScale > 1.0 {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
        }
        print("End zoom")
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("Zoomed")
    }
    
    @objc private func tapScreen() {
        print("tapped screen")
        if (self.navigationController?.isNavigationBarHidden)!{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(false, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    @objc private func doubleTapScreen(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: (scrollView.maximumZoomScale)/2, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    @objc func respondtoLongPress(gesture: UIGestureRecognizer) {
        if gesture is UILongPressGestureRecognizer {
            print("Long press")
            if (self.navigationController?.isToolbarHidden)!{
                
                //imageView.backgroundColor = UIColor.black
                
                //self.tabBarController?.tabBar.isHidden = false
            } else {
                //imageView.backgroundColor = UIColor.white
                //self.tabBarController?.tabBar.isHidden = true
                //print(self.tabBarController?.tabBar.isHidden)
            }
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if index <= photoAsset.count - 1 {
                    print(index)
                    print(photoAsset.count)
                    if index > 0 {
                        index -= 1
                        enlargeImage()
                    }
                }
                if (self.navigationController?.isToolbarHidden)!{
                    print("Swiped right")
                    //imageView.backgroundColor = UIColor.black
                    
                    //self.tabBarController?.tabBar.isHidden = false
                } else {
                    //imageView.backgroundColor = UIColor.white
                    //self.tabBarController?.tabBar.isHidden = true
                    //print(self.tabBarController?.tabBar.isHidden)
                }
            case UISwipeGestureRecognizerDirection.down:
                if (self.navigationController?.isToolbarHidden)!{
                    print("Touch began")
                    //imageView.backgroundColor = UIColor.black
                    //self.tabBarController?.tabBar.isHidden = false
                } else {
                    //imageView.backgroundColor = UIColor.white
                    //self.tabBarController?.tabBar.isHidden = true
                    //print(self.tabBarController?.tabBar.isHidden)
                }
            case UISwipeGestureRecognizerDirection.left:
                if index < photoAsset.count - 1 {
                    print(index)
                    print(photoAsset.count)
                    index += 1
                    enlargeImage()
                }
                if (self.navigationController?.isToolbarHidden)!{
                    print("TSwiped left")
                    //imageView.backgroundColor = UIColor.black
                    //self.tabBarController?.tabBar.isHidden = false
                } else {
                    //imageView.backgroundColor = UIColor.white
                    //self.tabBarController?.tabBar.isHidden = true
                    //print(self.tabBarController?.tabBar.isHidden)
                }
            case UISwipeGestureRecognizerDirection.up:
                if (self.navigationController?.isToolbarHidden)!{
                    print("Touch began")
                    //imageView.backgroundColor = UIColor.black
                    //self.tabBarController?.tabBar.isHidden = false
                } else {
                    //imageView.backgroundColor = UIColor.white
                    //self.tabBarController?.tabBar.isHidden = true
                    //print(self.tabBarController?.tabBar.isHidden)
                }
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func enlargeImage(){
        _ = PHImageManager.default().requestImage(for: self.photoAsset[self.index], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {(result, info) in
                //self.imageView.image = result
                //print(self.photoAsset[self.index].location.coordinate.longitude)
                //print(self.photoAsset[self.index].location?.coordinate.longitude)
                UIView.transition(with: self.imageView,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.imageView.image = result
                                  },
                                  completion: nil)
            
            
        })
    }
    
    @objc func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        var thumbnail = UIImage()
        manager.requestImage(for: asset, targetSize: thumbnail.size, contentMode: .aspectFit, options: nil, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
    let tapMaxDelay: Double = 0.3
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        let deadlineTime = DispatchTime.now() + tapMaxDelay
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            // Enough time has passed and the gesture was not recognized -> It has failed.
            if  self.state != UIGestureRecognizerState.ended {
                self.state = UIGestureRecognizerState.failed
            }
        }
    }
    
}



