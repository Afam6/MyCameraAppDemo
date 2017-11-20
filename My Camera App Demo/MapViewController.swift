//
//  MapViewController.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 20/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import MapKit
import Photos

 var mapPhotoAsset: PHFetchResult<PHAsset>!

class MapViewController: UIViewController, MKMapViewDelegate {
    
    class CustomMKPointAnnotation: MKPointAnnotation {
        var imageName: UIImage!
    }
    
    var index = 0

    @IBOutlet var mapView: MKMapView!
    @IBAction func mapSegementControl(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        
        print("added")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        
        print("map photo asset is:")
        if mapPhotoAsset != nil {
            print(mapPhotoAsset.count)
            var i = 0
            while i < mapPhotoAsset.count {
                if mapPhotoAsset[i].location != nil {
                    print(Double((mapPhotoAsset[i].location?.coordinate.longitude)!))
                    print("I am in !!")
                    let latitude = Double((mapPhotoAsset[i].location?.coordinate.latitude)!)
                    let longitude = Double((mapPhotoAsset[i].location?.coordinate.longitude)!)
                    let pictureCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
                    let a = CustomMKPointAnnotation()
                    a.coordinate = pictureCoordinate
                    a.title = "random place"
                    _ = PHImageManager.default().requestImage(for: mapPhotoAsset[i], targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                        
                        a.imageName = result!
                        
                    })
                    mapView.addAnnotation(a)
                    print("added")
                }
                
                i += 1
            }
        }
        
        
    }
    
    @objc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pok")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pok")
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let customMKPointAnnotation = annotation as! CustomMKPointAnnotation
        
        annotationView!.image = self.resizeImage(image: customMKPointAnnotation.imageName, targetSize: CGSize(width: 50, height: 50))
        
        /*
        if mapPhotoAsset != nil {
            var j = 0
            while j < mapPhotoAsset.count {
                if mapPhotoAsset[j].location != nil {
                    _ = PHImageManager.default().requestImage(for: mapPhotoAsset[j], targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                        
                        annotationView!.image = result
                        
                    })

                    //annotationView!.image = UIImage(named: "Autumn-Uni-Conference-2017-in-Shropshire.jpg")
                    
                }
                j += 1
            }
        }
        */
        print("annotation view is \(String(describing: annotationView!.image))")
        return annotationView
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }


}
