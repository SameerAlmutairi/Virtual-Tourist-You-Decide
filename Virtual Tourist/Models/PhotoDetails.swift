//
//  PhotoDetails
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 29/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import Foundation

struct PhotoDetails: Codable {
    let photoURL: String
    
    enum CodingKeys: String, CodingKey {
        case photoURL = "url_m"
    }
}
