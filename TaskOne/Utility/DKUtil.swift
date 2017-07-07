//
//  DKUtil.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func errorColor() -> UIColor {
        return UIColor.red
    }
    
    static func correctColor() -> UIColor {
        return UIColor.green
    }
    
    static func seamfoam() -> UIColor {
        return UIColor(colorLiteralRed: 86.0/255.0, green: 200.0/255.0, blue: 185.0/255.0, alpha: 1.0)
    }
    
    static func pink() -> UIColor {
        return UIColor(colorLiteralRed: 248.0/255.0, green: 16.0/255.0, blue: 102.0/255.0, alpha: 1.0)
    }
    
    static func greyish() -> UIColor {
        return UIColor(white: 90.0/255.0, alpha: 1.0)
    }

}
