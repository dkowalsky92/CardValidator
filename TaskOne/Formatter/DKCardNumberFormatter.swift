//
//  DKCardNumberFormatter.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit

class DKCardNumberFormatter: NSObject {
    
    var formerText: String?
    var formerCursorPosition: UITextRange?
    
    override init() {
        super.init()
    }
    
    func formatTextField(_ textField: UITextField) {
        guard let _text = textField.text, let _selectedTextRange = textField.selectedTextRange else {
            print("no text")
            return
        }
        
        var cursorPosition = textField.offset(from: textField.beginningOfDocument, to: _selectedTextRange.start)
        
        let cardNumberNoDigits = self.removeNonDigits(fromString: _text, preserveCursorPosition: &cursorPosition)
        
        if cardNumberNoDigits.count > 16 {
            textField.text = self.formerText
            textField.selectedTextRange = self.formerCursorPosition
            
            return
        }
        
        let cardNumberWithSpaces = self.insertSpaces(toString: cardNumberNoDigits, preserveCursorPosition: &cursorPosition)
        textField.text = cardNumberWithSpaces
        
        guard let targetPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition) else {
            print("no position")
            return
        }
        
        textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
    }
    
    private func removeNonDigits(fromString string: String, preserveCursorPosition position: inout Int) -> String {
        
        let originalCursorPosition = position
        
        var digitsOnlyString = ""
        let digitSet = CharacterSet.decimalDigits
        
        for (index, char) in string.unicodeScalars.enumerated() {
            if digitSet.contains(char) {
                let substring = String(char)
                digitsOnlyString.append(substring)
            } else {
                if (index < originalCursorPosition) {
                    position -= 1
                }
            }
        }
        
        return digitsOnlyString
    }
    
    func insertSpaces(toString string: String, preserveCursorPosition position: inout Int) -> String {
        
        var stringAddedSpaces = ""
        let originalCursorPosition = position
        
        for (index, char) in string.characters.enumerated() {
            if (index > 0) && (index % 4 == 0) {
                stringAddedSpaces.append(" ")
                
                if (index < originalCursorPosition) {
                    position += 1
                }
            }
            
            stringAddedSpaces.append(char)
        }
        
        return stringAddedSpaces
    }
    
    func insertSpaces(toString string: String) -> String {
        var stringAddedSpaces = ""
        
        for (index, char) in string.characters.enumerated() {
            if (index > 0) && (index % 4 == 0) {
                stringAddedSpaces.append(" ")
            }
            
            stringAddedSpaces.append(char)
        }
        
        return stringAddedSpaces
    }
}
