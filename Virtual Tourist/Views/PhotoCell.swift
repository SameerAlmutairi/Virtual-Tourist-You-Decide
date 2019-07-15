//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 02/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    // image
    var imageURL: String = ""
    @IBOutlet weak var imageView: UIImageView!
    
    // indicator
    @IBOutlet weak var cellActivityindicator: UIActivityIndicatorView!
}

