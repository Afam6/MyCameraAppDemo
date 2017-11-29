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

class MapViewController: UIViewController {
    
    var annotations = [ImageAnnotation]()
    var detectChange: Int = 0
    var image: UIImage?

    @IBOutlet var mapView: MKMapView!
    @IBAction func mapSegmentController(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("map view did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.mapView.delegate = self
        mapView.register(MarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.showsUserLocation = false
        
        AppUtility.lockOrientation(.all)
        
        print("map photo asset is:")
        if mapPhotoAsset != nil {
                print("Change occured")
                detectChange = mapPhotoAsset.count
                print(mapPhotoAsset.count)
                
                
                var allAnnotations = mapView.annotations
                mapView.removeAnnotations(allAnnotations)
                annotations.removeAll()
                
                var i = 0
                while i < mapPhotoAsset.count {
                    if mapPhotoAsset[i].location != nil {
                        print(Double((mapPhotoAsset[i].location?.coordinate.longitude)!))
                        print("I am in !!")
                        let latitude = Double((mapPhotoAsset[i].location?.coordinate.latitude)!)
                        let longitude = Double((mapPhotoAsset[i].location?.coordinate.longitude)!)
                        let pictureCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
                        let uiImage: UIImage?
                        _ = PHImageManager.default().requestImage(for: mapPhotoAsset[i], targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFit, options: nil, resultHandler: {(result, info) in
                            self.image = result
                            //self.image = self.resizeImage(image: result!, targetSize: CGSize(width: 50, height: 50))
                        })
                        print("Map image is !!!!!!!!!!!!!!!!!!")
                        uiImage = self.image
                        let a = ImageAnnotation(title: " ", color: UIColor.red, coordinate: pictureCoordinate, image: uiImage)
                        mapView.addAnnotation(a)
                        allAnnotations.append(a)
                        annotations.append(a)
                        print("added")
                    }
                    
                    i += 1
                }
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        AppUtility.lockOrientation(.portrait)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    
}
extension MapViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let test = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        test.title = "Photos"
        test.subtitle = nil
        return test
    }
}
