//
//  DKToolbar.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 07.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit

class DKToolbar: UIToolbar {
    
    var dismissButton: UIBarButtonItem!
    var readyButton: UIBarButtonItem!
    var textField: UITextField? {
        didSet {
            self.sizeToFit()
            self.textField?.inputAccessoryView = self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configure() {
        self.backgroundColor = .white
        self.barStyle = .default
        
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 44))
        customButton.setTitleColor(UIColor.seamfoam(), for: .normal)
        customButton.setTitle("Cancel", for: .normal)
        customButton.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        
        self.dismissButton = UIBarButtonItem(customView: customButton)
        
        let customButton2 = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 44))
        customButton2.setTitleColor(UIColor.seamfoam(), for: .normal)
        customButton2.setTitle("Done", for: .normal)
        customButton2.addTarget(self, action: #selector(dismiss(_:)), for: .touchUpInside)
        
        self.readyButton = UIBarButtonItem(customView: customButton2)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        self.items = [self.dismissButton, spacer, self.readyButton]
    }
    
    @objc func dismiss(_ sender: Any) {
        self.textField?.resignFirstResponder()
    }
}
