//
//  MarkerAnnotationView.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 28/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import MapKit

class MarkerAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? ImageAnnotation else { return }
            clusteringIdentifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
            markerTintColor = annotation.color
            //glyphText = "1"
            glyphImage = #imageLiteral(resourceName: "icons8-picture-50")
            canShowCallout = true
            //calloutOffset = CGPoint(x: -5, y: 5)
            //rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint(x:0, y:0),
                                                    size: CGSize(width: 50, height: 50)))
            mapsButton.setBackgroundImage(annotation.image, for: UIControlState())
            detailCalloutAccessoryView = mapsButton
            
            //let imageView = UIImageView.init(frame: CGRect(origin: CGPoint(x:5, y:5), size: CGSize(width: 50, height: 50)))
            //imageView.image = annotation.image
            //leftCalloutAccessoryView = imageView
            
        }
    }
}
