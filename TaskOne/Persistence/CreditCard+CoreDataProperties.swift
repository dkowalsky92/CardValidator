//
//  CreditCard+CoreDataProperties.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 06.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//
//

import Foundation
import CoreData


extension CreditCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CreditCard> {
        return NSFetchRequest<CreditCard>(entityName: "CreditCard")
    }

    @NSManaged public var bank: String?
    @NSManaged public var country: String?
    @NSManaged public var valid: Bool
}
