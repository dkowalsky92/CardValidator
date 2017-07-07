//
//  NumberFormatterTests.swift
//  TaskOneTests
//
//  Created by Dominik Kowalski on 06.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import XCTest
@testable import TaskOne

class CardNumberFormatterTests: XCTestCase {
    
    var mockTextField: UITextField!
    var mockNumber: String!
    var formatter: DKCardNumberFormatter!
    
    override func setUp() {
        formatter = DKCardNumberFormatter()
        mockNumber = "1111222233334444"
        mockTextField = UITextField()
        mockTextField.text = mockNumber
        
        super.setUp()
    }
    
    override func tearDown() {
        formatter = nil
        mockNumber = nil
        mockTextField = nil
        
        super.tearDown()
    }
    
    func testInsertSpaces() {
        let string = formatter.insertSpaces(toString: mockTextField.text!)
        
        XCTAssertTrue(string.count == 19)
        XCTAssertEqual(string, "1111 2222 3333 4444")
    }
}
