//
//  PhotosObj.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 29/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import Foundation

struct PhotosObj: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
//    let total: Int
    let photo: [PhotoDetails]
}
