//
//  DKButton.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit

fileprivate let cornerRadius: CGFloat = 4.0
fileprivate let shadowRadius: CGFloat = 4.0
fileprivate let opacity: Float = 1.0

class DKButton: UIButton {
    
    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        
        set {
            super.isEnabled = newValue
            
            if super.isEnabled {
                self.backgroundColor = UIColor.pink()
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.shadowColor = UIColor.black.withAlphaComponent(0.32).cgColor
            } else {
                self.backgroundColor = UIColor.clear
                self.layer.borderWidth = 1.0
                self.layer.borderColor = UIColor.white.withAlphaComponent(0.44).cgColor
                self.layer.shadowColor = UIColor.clear.cgColor
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
    
    private func configure() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(UIColor.white.withAlphaComponent(0.44), for: .disabled)
        
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.32).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
        self.layer.cornerRadius = cornerRadius
    }
}
