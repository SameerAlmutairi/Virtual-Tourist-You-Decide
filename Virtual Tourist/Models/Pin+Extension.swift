//
//  Pin+Extension.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 02/06/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import Foundation
import MapKit


extension Pin {
    
    // coordinate
    var coordinate: CLLocationCoordinate2D {
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        
        get {
            return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        }
    }
    

    // func awakeFromInsert
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
