//
//  TaskOneTests.swift
//  TaskOneTests
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import XCTest
@testable import TaskOne

class CardNumberGeneratorTests: XCTestCase {
    
    var mockBIN: String!
    
    override func setUp() {
        
        self.mockBIN = "55"
        
        super.setUp()
    }
    
    override func tearDown() {
        
        self.mockBIN = nil
        
        super.tearDown()
    }
    
    func testGeneratorLengthCorrect() {
        let number = DKNumberGenerator.generate(bin: mockBIN, length: 16)
        XCTAssertEqual(number.count, 16)
        
        let number2 = DKNumberGenerator.generate(bin: mockBIN, length: 15)
        XCTAssertEqual(number2.count, 15)
    }
}
