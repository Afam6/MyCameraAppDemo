//
//  ImageAnnotation.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 28/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import MapKit

final class ImageAnnotation: NSObject, MKAnnotation {
    var title: String?
    var color: UIColor
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    
    init(title: String?, color: UIColor, coordinate: CLLocationCoordinate2D, image: UIImage?) {
        self.title = title
        self.color = color
        self.coordinate = coordinate
        self.image = image
    }
 
}
