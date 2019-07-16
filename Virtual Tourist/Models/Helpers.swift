//
//  Helpers.swift
//  Virtual Tourist
//
//  Created by Sameer Almutairi on 16/07/2019.
//  Copyright © 2019 Sameer Almutairi. All rights reserved.
//

import UIKit

enum Helper {
    static func displayAlertMessage(_ viewController: UIViewController, _ title: String, _ message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dissmiss", style: .default, handler: nil))
            viewController.present(alert,animated: true, completion: nil)
        }
    }
}
