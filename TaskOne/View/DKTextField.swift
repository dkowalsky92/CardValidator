//
//  DKTextField.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit

fileprivate let cornerRadius: CGFloat = 4

class DKTextField: UITextField {
    
    var textSetClosure: (() -> Void)?
    var toolbar: DKToolbar!
    var errorLabel: UILabel! {
        didSet {
            self.errorLabel.numberOfLines = 0
            self.errorLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            self.errorLabel.textColor = UIColor.greyish()
            self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override var text: String? {
        get {
            return super.text
        }
        
        set {
            super.text = newValue
            
            if let _textSetClosure = textSetClosure {
                _textSetClosure()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 8)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 8, dy: 8)
    }
    
    private func configure() {
        self.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        self.textColor = UIColor.greyish()
        self.borderStyle = .none
        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
        
        self.errorLabel = UILabel()
        
        self.addSubview(self.errorLabel)
        
        let constraintLeading = self.errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
        let constraintTrailiing = self.errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8)
        let constraintTop = self.errorLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        let constraintHeight = self.errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 14)
        
        NSLayoutConstraint.activate([constraintLeading, constraintTrailiing, constraintHeight, constraintTop])
        
        self.toolbar = DKToolbar()
        self.toolbar.textField = self
    }
    
    func toggleError(_ hidden: Bool, withMessage message: String?) {
        if let _message = message {
            self.errorLabel.text = _message
        }
        
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.alpha = hidden ? 0.0 : 1.0
        }
    }

    override func becomeFirstResponder() -> Bool {
        self.layer.borderColor = UIColor.pink().cgColor
        self.layer.borderWidth = 2.0
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
        
        return super.resignFirstResponder()
    }
    
}
