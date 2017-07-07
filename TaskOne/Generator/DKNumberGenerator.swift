//
//  NumberGenerator.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit

class DKNumberGenerator: NSObject {
    
    class func generate(bin: String, length: Int) -> String {
        let randomNumberLength = length - (bin.count + 1)
        var newNumber = bin
        
        for _ in 0..<randomNumberLength {
            let rand = Int(arc4random_uniform(10))
            newNumber += String(rand)
        }
        
        let checkDigit = DKNumberGenerator.checkDigits(number: newNumber)
        newNumber.append(String(checkDigit))
        
        return newNumber
    }
    
// Luhn algorithm
    private class func checkDigits(number: String) -> Int {
        var sum = 0
        
        for (index, _) in number.enumerated() {
            let start = number.index(number.startIndex, offsetBy: index)
            let end = number.index(number.startIndex, offsetBy: index+1)
            let range = start..<end
            if var digit = Int(number.substring(with: range)) {
                if index % 2 == 0 {
                    digit = digit * 2
                    if digit > 9 {
                        digit = (digit / 10) + (digit % 10)
                    }
                }
                
                sum += digit
            }
        }
        
        let mod = sum % 10
        
        return ((mod == 0) ? 0 : 10 - mod)
    }
}
