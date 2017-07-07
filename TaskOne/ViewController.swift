//
//  ViewController.swift
//  TaskOne
//
//  Created by Dominik Kowalski on 05.07.2017.
//  Copyright © 2017 kowalsky's design. All rights reserved.
//

import UIKit
import CoreData

fileprivate let BIN: String = "45717360"

class ViewController: UIViewController, UIScrollViewDelegate {
    
    var creditCardControl: DKCreditCardControl!
    
    var scrollView: UIScrollView! {
        didSet {
            self.scrollView.showsHorizontalScrollIndicator = false
            self.scrollView.delegate = self
            self.scrollView.backgroundColor = .lightGray
        }
    }
    
    var generateButton: DKButton! {
        didSet {
            self.generateButton.setTitle("Generate", for: .normal)
            self.generateButton.addTarget(self, action: #selector(generate(_:)), for: .touchUpInside)
            self.generateButton.isEnabled = true
        }
    }
    
    var validateButton: DKButton! {
        didSet {
            self.validateButton.setTitle("Validate", for: .normal)
            self.validateButton.addTarget(self, action: #selector(validate(_:)), for: .touchUpInside)
            self.validateButton.isEnabled = false
        }
    }
    
    var messageLabel: UILabel! {
        didSet {
            self.messageLabel.textColor = UIColor.greyish()
            self.messageLabel.font = UIFont.boldSystemFont(ofSize: 17)
            self.messageLabel.text = "Valid"
            self.messageLabel.alpha = 0.0
            self.messageLabel.textAlignment = .center
            self.messageLabel.numberOfLines = 0
        }
    }
    
    var activityIndicator: UIActivityIndicatorView! {
        didSet {
            self.activityIndicator.color = UIColor.pink()
            self.activityIndicator.hidesWhenStopped = true
        }
    }
    
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.dataController?.managedObjectContext
        self.creditCardControl.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        self.view = configure()
    }
    
    func animateInfoMessage(_ message: String) {
        UIView.animate(withDuration: 0.3, animations: {
            self.messageLabel.alpha = 0.0
        }) { (completed) in
            if self.messageLabel.text != message {
                self.messageLabel.text = message
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.messageLabel.alpha = 1.0
            })
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func validate(_ sender: Any) {
        self.dismissKeyboard()
        
        guard let _text = self.creditCardControl.number else {
            
            self.animateInfoMessage("Insuffcient data, fill in the input forms and revalidate")
            
            return
        }
        
        let fr: NSFetchRequest<CreditCard> = CreditCard.fetchRequest()
        fr.predicate = NSPredicate(format: "number = %@", _text.replacingOccurrences(of: " ", with: ""))
        
        guard let card: CreditCard = try! self.managedObjectContext.fetch(fr).first else {
            
            self.animateInfoMessage("Insuffcient data, fill in the input forms and revalidate")
            
            return
        }
        
        self.activityIndicator.startAnimating()
        
        guard let request = DKValidationURLRequest(card: card.objectID) else {
            return
        }
        
        request.start { (updatedCard, response, error) in
            self.activityIndicator.stopAnimating()
            
            if let _ = error {
                if let message = error as? (String, String) {
                    self.animateInfoMessage("Error \(message.1) - \(message.0)")
                } else if let _error = error as? Error {
                    self.animateInfoMessage(_error.localizedDescription)
                }
                
                return
            }
            
            if let _card = updatedCard {
                self.animateInfoMessage(_card.valid ? "Card is valid!" : "Not valid :(")
                return
            }
        }
    }
    
    @objc func generate(_ sender: Any) {
        let randomNumber = DKNumberGenerator.generate(bin: BIN, length: 16)
        let cvc = randomNumber.substring(from: randomNumber.index(randomNumber.endIndex, offsetBy: -3))
        let randomTimeInterval = arc4random_uniform(999999999)
        let expirationDate = Date().addingTimeInterval(TimeInterval(randomTimeInterval))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        
        print(randomNumber)
        print(cvc)
        print(formatter.string(from: expirationDate))
        
        let fr: NSFetchRequest<CreditCard> = CreditCard.fetchRequest()
        fr.predicate = NSPredicate(format: "number = %@", randomNumber)
        
        let card: CreditCard = try! self.managedObjectContext.fetch(fr).first ?? NSEntityDescription.insertNewObject(forEntityName: "CreditCard", into: self.managedObjectContext) as! CreditCard
        card.valueSetClosure = { (key) in
            self.creditCardControl.updateTextFields(card)
        }
        
        card.number = randomNumber
        card.cvc = cvc
        card.expirationDate = formatter.string(from: expirationDate)
        
        self.validateButton.isEnabled = true
    }
}

// DKCreditCardControlDelegate implementation
extension ViewController: DKCreditCardControlDelegate {
    func didBeginEdittingTextField(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentOffset = CGPoint(x: 0.0, y: textField.frame.maxY)
        }
    }
    
    func didFillTextFields(_ cardId: NSManagedObjectID?) {
        if let _ = cardId {
            self.validateButton.isEnabled = true
        } else {
            self.validateButton.isEnabled = false
        }
    }
}

// Keyboard management
extension ViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let height = self.view.convert(keyboardRect, from: nil).height
        
        let insets = UIEdgeInsetsMake(0.0, 0.0, fabs(self.view.frame.height-height), 0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let insets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
}

// View setup
extension ViewController {
    private func configure() -> UIView {
        self.scrollView = UIScrollView(frame: UIScreen.main.bounds)
        
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = UIColor.lightGray
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        self.scrollView.addSubview(mainView)
        
        let mainConstraintTop = mainView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        let mainConstraintBottom = mainView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        let mainConstraintLeading = mainView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        let mainConstraintTrailing = mainView.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        let mainConstraintHeight = mainView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        let mainConstraintWidth = mainView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        
        NSLayoutConstraint.activate([mainConstraintTop, mainConstraintBottom, mainConstraintWidth, mainConstraintHeight, mainConstraintLeading, mainConstraintTrailing])
        
        self.creditCardControl = DKCreditCardControl()
        self.creditCardControl.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(self.creditCardControl)
        
        let constraintCenterX = self.creditCardControl.centerXAnchor.constraint(equalTo: mainView.centerXAnchor)
        let constraintTop = self.creditCardControl.topAnchor.constraint(greaterThanOrEqualTo: mainView.topAnchor, constant: 150)
        let constraintWidth = self.creditCardControl.widthAnchor.constraint(equalToConstant: 300)
        let constraintHeight = self.creditCardControl.heightAnchor.constraint(equalToConstant: 180)
        
        NSLayoutConstraint.activate([constraintWidth, constraintHeight, constraintCenterX, constraintTop])
        
        self.validateButton = DKButton()
        self.validateButton.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(self.validateButton)
        
        let validateButtonConstraintLeading = self.validateButton.leadingAnchor.constraint(equalTo: self.creditCardControl.leadingAnchor)
        let validateButtonConstraintTop = self.validateButton.topAnchor.constraint(equalTo: self.creditCardControl.bottomAnchor, constant: 16)
        let validateButtonConstraintWidth = self.validateButton.widthAnchor.constraint(equalTo: self.creditCardControl.widthAnchor, multiplier: 0.5, constant: -8)
        let validateButtonConstraintHeight = self.validateButton.heightAnchor.constraint(equalToConstant: 54)
        
        NSLayoutConstraint.activate([validateButtonConstraintTop, validateButtonConstraintWidth, validateButtonConstraintHeight, validateButtonConstraintLeading])
        
        self.generateButton = DKButton()
        self.generateButton.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(self.generateButton)
        
        let generateButtonConstraintLeading = self.generateButton.leadingAnchor.constraint(equalTo: self.validateButton.trailingAnchor, constant: 16)
        let generateButtonConstraintTop = self.generateButton.topAnchor.constraint(equalTo: self.validateButton.topAnchor, constant: 0)
        let generateButtonConstraintTrailing = self.generateButton.trailingAnchor.constraint(equalTo: self.creditCardControl.trailingAnchor)
        let generateButtonConstraintHeight = self.generateButton.heightAnchor.constraint(equalToConstant: 54)
        
        NSLayoutConstraint.activate([generateButtonConstraintLeading, generateButtonConstraintTop, generateButtonConstraintTrailing, generateButtonConstraintHeight])
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(self.activityIndicator)
        
        let activityIndicatorConstraintCenterX = self.activityIndicator.centerXAnchor.constraint(equalTo: mainView.centerXAnchor)
        let activityIndicatorConstraintTop = self.activityIndicator.topAnchor.constraint(equalTo: self.validateButton.bottomAnchor, constant: 16)
        
        NSLayoutConstraint.activate([activityIndicatorConstraintCenterX, activityIndicatorConstraintTop])
        
        self.messageLabel = UILabel()
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(self.messageLabel)
        
        let messageLabelConstraintLeading = self.messageLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 32)
        let messageLabelConstraintTop = self.messageLabel.topAnchor.constraint(equalTo: self.activityIndicator.bottomAnchor, constant: 16)
        let messageLabelConstraintTrailing = self.messageLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -32)
        let messageLabelConstraintHeight = self.messageLabel.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([messageLabelConstraintLeading, messageLabelConstraintTop, messageLabelConstraintTrailing, messageLabelConstraintHeight])
        
        return scrollView
    }
}

