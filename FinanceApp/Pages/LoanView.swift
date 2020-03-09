//
//  LoanView.swift
//  FinanceApp
//
//  Created by Abduvokhid Akhmedov on 07/03/2020.
//  Copyright © 2020 Abduvokhid Akhmedov. All rights reserved.
//

import UIKit

class LoanView: UIView, UITextFieldDelegate, Slide {

    enum LoanFinding {
        case Empty
        case InitialAmount
        case PaymentAmount
        case NumberOfMonths
    }
    
    @IBOutlet var cardView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var initialAmountTF: UITextField!
    @IBOutlet weak var paymentAmountTF: UITextField!
    @IBOutlet weak var interestRateTF: UITextField!
    @IBOutlet weak var numberOfMonthsTF: UITextField!
    
    @IBOutlet weak var cardViewTitle: UILabel!
    @IBOutlet weak var cardViewTitleSpace: UIView!

    var finding = LoanFinding.Empty
    let defaults = UserDefaults.standard
    
    override func awakeFromNib() {
        cardView.layer.cornerRadius = 20
        //cardView.layer.shadowPath = UIBezierPath(rect: cardView.bounds).cgPath
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowOpacity = 0.2
        
        calculateButton.layer.cornerRadius = 5
        initialAmountTF.layer.cornerRadius = 5
        paymentAmountTF.layer.cornerRadius = 5
        interestRateTF.layer.cornerRadius = 5
        numberOfMonthsTF.layer.cornerRadius = 5
        
        let resignSelector = #selector(saveFields)
        NotificationCenter.default.addObserver(self, selector: resignSelector, name: UIApplication.willResignActiveNotification, object: nil)
        
        readFields()
    }
    
    func keyboardOpened() {
        UIView.transition(with: superview!,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.titleLabel.text = self?.cardViewTitle.text!
            }, completion: nil)
        UIView.animate(withDuration: 0.05, animations: {
            self.cardViewTitle.alpha = 0
            self.cardViewTitleSpace.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.cardViewTitle.isHidden = true
                self.cardViewTitleSpace.isHidden = true
            })
        })
    }
    
    func keyboardClosed() {
        UIView.transition(with: superview!,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.titleLabel.text = "Finance App"
            }, completion: nil)
        UIView.animate(withDuration: 0.05, animations: {
            self.cardViewTitle.alpha = 1
            self.cardViewTitleSpace.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.cardViewTitle.isHidden = false
                self.cardViewTitleSpace.isHidden = false
            })
        })
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        let interestRate = interestRateTF.validatedDouble
        let initialAmount = initialAmountTF.validatedDouble
        let paymentAmount = paymentAmountTF.validatedDouble
        let numberOfMonths = numberOfMonthsTF.validatedDouble
        
        let validationError = validateInput(interestRate: interestRate, initialAmount: initialAmount, paymentAmount: paymentAmount, numberOfYears: numberOfMonths)
        
        let color = sender.backgroundColor
        
        if validationError == nil {
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.calculateButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                sender.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
                self.topBarView.backgroundColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
            }, completion: {_ in
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.calculateButton.transform = CGAffineTransform.identity
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, delay: 0.6, animations: {() -> Void in
                        sender.backgroundColor = color
                        self.topBarView.backgroundColor = color
                    })
                })
            })
            
            switch finding {
            case .InitialAmount:
                let result = MortgageHelper.initialValue(paymentAmount: paymentAmount!, interestRate: interestRate!, numberOfYears: numberOfMonths! / 12)
                initialAmountTF.text = "£ " + String(format: "%.2f", result)
            case .NumberOfMonths:
                let result = MortgageHelper.numberOfYears(initialAmount: initialAmount!, interestRate: interestRate!, paymentAmount: paymentAmount!)
                numberOfMonthsTF.text = String(format: "%.2f", result * 12)
            case .PaymentAmount:
                let result = MortgageHelper.paymentAmount(initialAmount: initialAmount!, interestRate: interestRate!, numberOfYears: numberOfMonths! / 12)
                paymentAmountTF.text = "£ " + String(format: "%.2f", result)
            default:
                return
            }
        } else {
            let alertView = HomePageViewController.parentController.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
            alertView.alertTitle = "Validation error!"
            alertView.alertText = validationError!
            alertView.modalPresentationStyle = .overCurrentContext
            alertView.modalTransitionStyle = .crossDissolve
            HomePageViewController.parentController.present(alertView, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func textFieldEdited(_ sender: UITextField) {
        if sender.filteredText == "" {
            sender.text = sender.filteredText
            return
        }
        switch sender.tag {
        case 1:
            sender.text = "£ " + sender.filteredText
        case 2:
            sender.text = sender.filteredText + " %"
        default:
            break
        }
    }
    
    func validateInput(interestRate: Double!, initialAmount: Double!, paymentAmount: Double!, numberOfYears: Double!) -> String! {
        var counter = 0
        
        if (initialAmount == nil) {
            counter += 1
            finding = .InitialAmount
        }
        
        if (paymentAmount == nil) {
            counter += 1
            finding = .PaymentAmount
        }
        
        if (numberOfYears == nil) {
            counter += 1
            finding = .NumberOfMonths
        }
        
        if counter > 1 {
            finding = .Empty
            return "Only one text field can be empty!\n\nPlease, read the help page to get more information!"
        }
        
        if interestRate == nil {
            return "Interest rate cannot be empty!\n\nPlease, read the help page to get more information!"
        }
        
        if counter == 0 && finding == .Empty {
            finding = .Empty
            return "At least one text field must be empty!\n\nPlease, read the help page to get more information!"
        }
        
        if paymentAmount != nil && initialAmount != nil {
            if paymentAmount > initialAmount && finding != .PaymentAmount {
                finding = .Empty
                return "Payment amount cannot be more than initial amount!"
            }
        }
        
        if initialAmount != nil && initialAmount == 0 {
            finding = .Empty
            return "Initial amount cannot be zero!"
        }
        
        if paymentAmount != nil && paymentAmount == 0 {
            finding = .Empty
            return "Payment amount cannot be zero!"
        }
        
        if numberOfYears != nil && numberOfYears == 0 {
            finding = .Empty
            return "Number of months cannot be zero!"
        }
        
        return nil
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        sender.layer.cornerRadius = 5
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            sender.tintColor = .white
            sender.backgroundColor = UIColor(red:0.27, green:0.41, blue:0.78, alpha:1.0)
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                sender.tintColor = UIColor(red:0.88, green:0.89, blue:0.90, alpha:1.0)
                sender.backgroundColor = .none
            })
        })
        
        UIView.transition(with: cardView,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.initialAmountTF.text = ""
                            self?.paymentAmountTF.text = ""
                            self?.interestRateTF.text = ""
                            self?.numberOfMonthsTF.text = ""
            }, completion: nil)
    }
    
    @IBAction func textFieldEditBegin(_ sender: UITextField) {
        sender.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = textField.filteredText
        
        if let char = string.cString(using: String.Encoding.utf8){
            let isBackspace = strcmp(char, "\\b")
            if (isBackspace == -92){
                textField.text = String(newText.dropLast()) + " "
                return true
            }
        }
        
        let stringParts = newText.components(separatedBy: ".")
        
        if stringParts.count > 1 && string == "." {
            return false
        }
        
        if (stringParts.count == 2 && stringParts[1].count == 2){
            return false
        }
        
        if textField.filteredText == "0" && string != "." {
            textField.text = ""
        }
        
        if textField.filteredText == "" && string == "." {
            textField.text = "0"
        }
        
        return true
    }
    
    @objc func saveFields() {
        defaults.set(initialAmountTF.text, forKey: "loanInitialAmount")
        defaults.set(paymentAmountTF.text, forKey: "loanPaymentAmount")
        defaults.set(numberOfMonthsTF.text, forKey: "loanNumberOfMonths")
        defaults.set(interestRateTF.text, forKey: "loanInterestRate")
    }
    
    func readFields(){
        initialAmountTF.text = defaults.string(forKey: "loanInitialAmount")
        paymentAmountTF.text = defaults.string(forKey: "loanPaymentAmount")
        numberOfMonthsTF.text = defaults.string(forKey: "loanNumberOfMonths")
        interestRateTF.text = defaults.string(forKey: "loanInterestRate")
    }
}