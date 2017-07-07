//
//  AsyncTests.swift
//  TaskOneTests
//
//  Created by Dominik Kowalski on 06.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import XCTest
import CoreData
@testable import TaskOne

class AsyncTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    var request: DKValidationURLRequest!
    var mockCard: CreditCard!
    
    override func setUp() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = delegate.dataController?.managedObjectContext
        self.managedObjectContext.performAndWait {
            self.mockCard = NSEntityDescription.insertNewObject(forEntityName: "CreditCard", into: self.managedObjectContext) as! CreditCard
            self.mockCard.number = "1111222233334444"
            self.mockCard.cvc = "444"
            self.mockCard.expirationDate = "12/20"
        }
        
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        self.managedObjectContext.performAndWait {
            self.managedObjectContext.delete(self.mockCard)
        }
        self.request = nil
        self.managedObjectContext = nil
        
        super.tearDown()
    }
    
    func testCardValidationCardFormatTooShort() {
        self.mockCard.number = "1111222233"
        request = DKValidationURLRequest(card: self.mockCard.objectID)
        let completionInvoked = expectation(description: "Completion invoked")
        let errorInvoked = expectation(description: "Error invoked")
        
        var value: Any?
        
        self.request.start { (updatedCard, httpResponse, httpError) in
            
            completionInvoked.fulfill()
            if let _error = httpError {
                errorInvoked.fulfill()
                value = _error
            }
            
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        guard let errorTuple = value as? (String, String) else {
            XCTFail("Error type is incorrect")
            return
        }
        
        XCTAssertTrue(errorTuple.0 == "Invalid Credit Card or Debit Card Number")
        XCTAssertTrue(errorTuple.1 == "1014")
    }
    
    func testCardNumberGeneratorFormatIsValid() {
        let number = DKNumberGenerator.generate(bin: "55", length: 16)
        self.mockCard.number = number
        request = DKValidationURLRequest(card: self.mockCard.objectID)
        let completionInvoked = expectation(description: "Completion invoked")
        let responseInvoked = expectation(description: "Response invoked")
        
        var value: Any?
        
        self.request.start { (updatedCard, httpResponse, httpError) in
            
            completionInvoked.fulfill()
            
            if let _httpResponse = httpResponse {
                responseInvoked.fulfill()
                value = _httpResponse
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        guard let response = value as? HTTPURLResponse else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(response.statusCode, 200)
    }
}
