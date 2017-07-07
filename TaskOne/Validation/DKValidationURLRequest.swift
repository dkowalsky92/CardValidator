//
//  ValidationURLRequest.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit
import CoreData
//0214138f76f47d7697ff80eb69cde89b 5232a9bca11e25c0f8eb4313ff2644be
fileprivate let API_KEY: String = "5232a9bca11e25c0f8eb4313ff2644be"

class DKValidationURLRequest: NSObject {
    
    private var session: URLSession!
    private var request: URLRequest!
    private var managedObjectContext: NSManagedObjectContext!
    
    var card: CreditCard!
    
    init?(card: NSManagedObjectID) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.dataController?.managedObjectContext
        
        self.card = self.managedObjectContext.object(with: card) as! CreditCard
        
        guard let _number = self.card.number else {
            return nil
        }
        
        let url = URL(string: "https://api.bincodes.com/cc/?format=json&api_key=\(API_KEY)&cc=\(_number.replacingOccurrences(of: " ", with: ""))")
        request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        
        session = URLSession(configuration: config)
    }
    
    func start(completion: ((_ card: CreditCard?, _ response: URLResponse?, _ error: Any?) -> Void)?) {
        
        session.dataTask(with: self.request) { (data, response, error) in
            self.managedObjectContext.perform({
                if let _error = error {
                    DispatchQueue.main.async {
                        if let _completion = completion {
                            _completion(nil, response, _error)
                        }
                    }
                    
                    return
                }
                
                guard let _data = data else {
                    DispatchQueue.main.async {
                        if let _completion = completion {
                            _completion(nil, response, nil)
                        }
                    }
                    
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: _data, options: [])
                
                if let dictionary = json as? [String : Any] {
                    print(dictionary)
                    
                    if let message = dictionary["message"], let error = dictionary["error"] {
                        DispatchQueue.main.async {
                            if let _completion = completion {
                                _completion(nil, response, (message, error))
                            }
                        }
                        
                        return
                    }
                    
                    self.card.update(json: dictionary)
                    
                    DispatchQueue.main.async {
                        if let _completion = completion {
                            _completion(self.card, response, nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if let _completion = completion {
                            _completion(nil, response, nil)
                        }
                    }
                }
            })
        }.resume()
    }
}
