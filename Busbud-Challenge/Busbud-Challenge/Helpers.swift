//
//  Helpers.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import Foundation
import UIKit

// Convert UInt Hex to UIColor
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// Simple Alert class
public class Alert: NSObject {
    
    class func Warning(delegate: UIViewController, message: String) {
        var alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        delegate.presentViewController(alert, animated: true, completion: nil)
    }
    
}
