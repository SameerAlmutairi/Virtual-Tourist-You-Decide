//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 29/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: PhotosObj
    let stat: String
}
