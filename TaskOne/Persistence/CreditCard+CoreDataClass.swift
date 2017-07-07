//
//  CreditCard+CoreDataClass.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 06.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CreditCard)
public class CreditCard: NSManagedObject {
    
    var valueSetClosure: ((_ key: String) -> Void)?
    
    public var cvc: String? {
        set {
            self.willChangeValue(forKey: "cvc")
            self.setPrimitiveValue(newValue, forKey: "cvc")
            self.didChangeValue(forKey: "cvc")
            
            if let _valueSetClosure = self.valueSetClosure {
                _valueSetClosure(self.cvc!)
            }
        }
        
        get {
            self.willAccessValue(forKey: "cvc")
            let val = self.primitiveValue(forKey: "cvc") as? String
            self.didAccessValue(forKey: "cvc")
            return val
        }
    }
    
    public var expirationDate: String? {
        set {
            self.willChangeValue(forKey: "expirationDate")
            self.setPrimitiveValue(newValue, forKey: "expirationDate")
            self.didChangeValue(forKey: "expirationDate")
            
            if let _valueSetClosure = self.valueSetClosure {
                _valueSetClosure(self.expirationDate!)
            }
        }
        
        get {
            self.willAccessValue(forKey: "expirationDate")
            let val = self.primitiveValue(forKey: "expirationDate") as? String
            self.didAccessValue(forKey: "expirationDate")
            return val
        }
    }
    
    public var number: String? {
        set {
            self.willChangeValue(forKey: "number")
            self.setPrimitiveValue(newValue, forKey: "number")
            self.didChangeValue(forKey: "number")
            
            if let _valueSetClosure = self.valueSetClosure {
                _valueSetClosure(self.number!)
            }
        }
        
        get {
            self.willAccessValue(forKey: "number")
            let val = self.primitiveValue(forKey: "number") as? String
            self.didAccessValue(forKey: "number")
            return val
        }
    }
    
    func update(json: [String : Any]) {
        if let isValid = json["valid"] as? String {
            self.valid = (isValid == "true") ? true : false
        }
        
        if let bank = json["bank"] as? String {
            self.bank = bank
        }
        
        if let country = json["country"] as? String {
            self.country = country
        }
    }
}
