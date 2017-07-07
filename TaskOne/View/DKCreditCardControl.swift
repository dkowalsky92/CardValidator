//
//  DKCreditCardControl.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit
import CoreData

fileprivate let cornerRadius: CGFloat = 15.0
fileprivate let shadowRadius: CGFloat = 4.0
fileprivate let opacity: Float = 1.0

protocol DKCreditCardControlDelegate {
    func didFillTextFields(_ cardId: NSManagedObjectID?)
    func didBeginEdittingTextField(_ textField: UITextField)
}

class DKCreditCardControl: UIView, UITextFieldDelegate {
    
    let cardNumberFormatter: DKCardNumberFormatter = DKCardNumberFormatter()
    
    var bankNumberTextField: DKTextField!
    var expirationDateTextField: DKTextField!
    var cvcDateTextField: DKTextField!
    
    var datePicker: DKPickerView! {
        didSet {
            datePicker.dateSelectedClosure = { (month, year) in
                let stringYear = String(year)
                let shortYear = stringYear.substring(from: stringYear.index(stringYear.startIndex, offsetBy: 2))
                
                var stringMonth = String(month)
                if month <= 9 {
                    stringMonth = "0\(stringMonth)"
                }
                self.expirationDateTextField.text = "\(stringMonth)/\(shortYear)"
            }
        }
    }
    
    var number: String?
    var cvc: String?
    var expirationDate: String?
    
    var managedObjectContext: NSManagedObjectContext!
    
    var delegate: DKCreditCardControlDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureConstraints()
        self.setupView()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.dataController?.managedObjectContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateTextFields(_ card: CreditCard) {
        if let cvc = card.cvc {
            self.cvcDateTextField.text = cvc
        }
        
        if let number = card.number {
            self.bankNumberTextField.text = self.cardNumberFormatter.insertSpaces(toString: number)
        }
        
        if let expirationDate = card.expirationDate {
            self.expirationDateTextField.text = expirationDate
        }
    }
    
    func verifyInput() {
        if ((self.number != nil && self.number?.count == 19) && (self.cvc != nil && self.cvc?.count == 3) && (self.expirationDate != nil && self.expirationDate?.count == 5)) {
            
            let fr: NSFetchRequest<CreditCard> = CreditCard.fetchRequest()
            fr.predicate = NSPredicate(format: "number = %@", self.number!)
            
            let card: CreditCard = try! self.managedObjectContext.fetch(fr).first ?? NSEntityDescription.insertNewObject(forEntityName: "CreditCard", into: self.managedObjectContext) as! CreditCard
            
            card.number = self.number!.replacingOccurrences(of: " ", with: "")
            card.cvc = self.cvc
            card.expirationDate = self.expirationDate
            
            if let _delegate = self.delegate {
                _delegate.didFillTextFields(card.objectID)
            }
        } else {
            if let _delegate = self.delegate {
                _delegate.didFillTextFields(nil)
            }
        }
    }
    
// MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let _delegate = delegate {
            _delegate.didBeginEdittingTextField(textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case self.bankNumberTextField:
            
            cardNumberFormatter.formerText = textField.text
            cardNumberFormatter.formerCursorPosition = textField.selectedTextRange
            
            return true
        case self.cvcDateTextField:
            guard let text = textField.text else { return true }
            
            let set = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: set)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            if string != numberFiltered {
                return false
            }
            
            let newLength = text.characters.count + string.characters.count - range.length
            
            if newLength > 3 {
                return false
            }
            
            return true
        default:
            return true
        }
    }
    
    @objc func textFieldValueChanged(_ textField: UITextField) {
        switch textField {
        case self.bankNumberTextField:
            cardNumberFormatter.formatTextField(textField)
            break
        case self.cvcDateTextField:
            self.cvcDateTextField.text = textField.text
            break
        case self.expirationDateTextField:
            self.expirationDateTextField.text = textField.text
            break
        default:
            break
        }
    }
}

// View setup
extension DKCreditCardControl {
    
    func configureConstraints() {
        self.bankNumberTextField = DKTextField()
        self.bankNumberTextField.placeholder = "XXXX XXXX XXXX XXXX"
        self.bankNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.bankNumberTextField)
        
        let bankNumberTopConstraint = self.bankNumberTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        let bankNumberLeadingConstraint = self.bankNumberTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        let bankNumberTrailingConstraint = self.bankNumberTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        let bankNumberHeightConstraint = self.bankNumberTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        
        NSLayoutConstraint.activate([bankNumberTopConstraint, bankNumberHeightConstraint, bankNumberLeadingConstraint, bankNumberTrailingConstraint])
        
        self.expirationDateTextField = DKTextField()
        self.expirationDateTextField.placeholder = "MM/YY"
        self.expirationDateTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.expirationDateTextField)
        
        let expirationDateTopConstraint = self.expirationDateTextField.topAnchor.constraint(equalTo: self.bankNumberTextField.bottomAnchor, constant: 24)
        let expirationDateLeadingConstraint = self.expirationDateTextField.leadingAnchor.constraint(equalTo: self.bankNumberTextField.leadingAnchor)
        let expirationDateWidthConstraint = self.expirationDateTextField.widthAnchor.constraint(greaterThanOrEqualTo: self.widthAnchor, multiplier: 0.5, constant: -24)
        let expirationDateHeightConstraint = self.expirationDateTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        
        NSLayoutConstraint.activate([expirationDateTopConstraint, expirationDateLeadingConstraint, expirationDateWidthConstraint, expirationDateHeightConstraint])
        
        self.cvcDateTextField = DKTextField()
        self.cvcDateTextField.placeholder = "CVC"
        self.cvcDateTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.cvcDateTextField)
        
        let cvcTopConstraint = self.cvcDateTextField.topAnchor.constraint(equalTo: self.expirationDateTextField.topAnchor, constant: 0)
        let cvcLeadingConstraint = self.cvcDateTextField.leadingAnchor.constraint(equalTo: self.expirationDateTextField.trailingAnchor, constant: 16)
        let cvcWidthConstraint = self.cvcDateTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5, constant: -24)
        let cvcHeightConstraint = self.cvcDateTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        
        NSLayoutConstraint.activate([cvcTopConstraint, cvcLeadingConstraint, cvcWidthConstraint, cvcHeightConstraint])
        
    }
    
    func setupView() {
        let shadowColor = UIColor.black.withAlphaComponent(0.2)
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
        self.layer.cornerRadius = cornerRadius
        self.layer.backgroundColor = UIColor.seamfoam().cgColor
        
        self.datePicker = DKPickerView()
        
        self.bankNumberTextField.delegate = self
        self.bankNumberTextField.keyboardType = .numberPad
        self.bankNumberTextField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.bankNumberTextField.textSetClosure = {
            self.number = self.bankNumberTextField.text
            if let _number = self.number {
                if _number.count != 0 && _number.count != 19 {
                    self.bankNumberTextField.toggleError(false, withMessage: "Card number is too short")
                } else {
                    self.bankNumberTextField.toggleError(true, withMessage: nil)
                }
            } else {
                self.bankNumberTextField.toggleError(false, withMessage: nil)
            }
            
            self.verifyInput()
        }
        
        self.cvcDateTextField.delegate = self
        self.cvcDateTextField.keyboardType = .numberPad
        self.cvcDateTextField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.cvcDateTextField.textSetClosure = {
            self.cvc = self.cvcDateTextField.text
            if let _cvc = self.cvc {
                if _cvc.count != 0 && _cvc.count != 3 {
                    self.cvcDateTextField.toggleError(false, withMessage: "CVC number is too short")
                } else {
                    self.cvcDateTextField.toggleError(true, withMessage: nil)
                }
            } else {
                self.cvcDateTextField.toggleError(false, withMessage: nil)
            }
            
            self.verifyInput()
        }
        
        self.expirationDateTextField.delegate = self
        self.expirationDateTextField.inputView = self.datePicker
        self.expirationDateTextField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.expirationDateTextField.textSetClosure = {
            self.expirationDate = self.expirationDateTextField.text
            if let _expirationDate = self.expirationDate {
                if _expirationDate.count != 0 && _expirationDate.count != 5 {
                    self.expirationDateTextField.toggleError(false, withMessage: "Date format is incorrect")
                } else {
                    self.expirationDateTextField.toggleError(true, withMessage: nil)
                }
            } else {
                self.expirationDateTextField.toggleError(false, withMessage: nil)
            }
            
            self.verifyInput()
        }
    }
}
