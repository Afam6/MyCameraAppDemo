//
//  PhotoCollectionViewCell.swift
//  My Camera App Demo
//
//  Created by Afam Ezechukwu on 18/11/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    @objc func setThumbnailImage(thumbnailImage: UIImage){
        self.imageView.image = thumbnailImage
    }
}
